module ActsAsApiAuthable
  module Warden
    class HttpOnlyCookieStrategy < ::Warden::Strategies::Base
      def valid?
    #    errors.add(:id, "Not present or valid") unless cookie_id.present?
        cookie_id.present?
    #    errors.empty?
      end

      def authenticate!
        token = UserToken.find_by_id(cookie_id)
        token_valid = !token.nil? && !token.device?
        unless token_valid
          secret = "JUNKSECRET"
        else
          if token.expired?
            token.destroy
            secret = "JUNKSECRET"
            token_valid = false
          else
            secret = token.secret
          end
        end

        if (request.cookies.has_key? "secret")
          cookie_secret = Base64.decode64(request.cookies["secret"])
        else
          cookie_secret = "JUNKSECRET"
          token_valid = false
        end

        if secret.length < cookie_secret.length
          token_valid = false
          secret = secret.ljust(cookie_secret.length, "0000")
        elsif cookie_secret.length < secret.length
          token_valid = false
          cookie_secret = cookie_secret.ljust(secret.length, "0000")
        end

        token_valid = token_valid && Rack::Utils.secure_compare(secret, cookie_secret)

        token.update_expiry! if token_valid

        token_valid ? success!(token.user) : fail!('strategies.authentication_cookie.failed')
      end

      private
      def parse_token
        @token_id = nil
        auth_value = ActsAsApiAuthable::Util::AuthorizationHeader.new(request.get_header("HTTP_AUTHORIZATION"))
        return if auth_value.type != :cookie

        @token_id = parse_uuid(auth_value[:id]) if auth_value.has_param?(:id)
      end

      def parse_uuid(uuidstring)
        if uuidstring.ends_with?("=")
          raw = Base64.decode64(uuidstring)
          return UUIDTools::UUID.parse_raw(raw) if raw.length == 16
        elsif uuidstring.index("-").present?
          begin
            return UUIDTools::UUID.parse(uuidstring)
          rescue ArgumentError
            return nil
          end
        else
          begin
            UUIDTools::UUID.parse_hexdigest(uuidstring)
          rescue ArgumentError
            return nil
          end
        end
      end

      def cookie_id
        parse_token unless @token_id.present?
        @token_id
      end
    end
  end
end
