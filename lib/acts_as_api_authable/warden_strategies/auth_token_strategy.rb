module ActsAsApiAuthable
  class AuthTokenStrategy < ::Warden::Strategies::Base
    @@max_token_age = 60
    @@max_skew = 5
    @@invalid_time_allowed = false
    @@unsigned_requests_allowed = false

    def valid?
      errors.add(:id, "Not present or valid") unless token_id.present?
      unless token_time.present?
        errors.add(:time, "Not present or valid")
      else
        unless token_in_time_window?(token_time)
          errors.add(:time, "Not in a valid time window")
        end
      end
      errors.add(:signature, "Not present or valid") unless token_signature.present?
      errors.empty?
    end

    def authenticate!
      token = UserToken.find_by_id(token_id)
      token_valid = !token.nil? && token.device?
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

      unless @@unsigned_requests_allowed
        signature = generate_signature(request, secret, @token[:raw_time])
        sent_signature = parse_signature(@token[:signature])
        if sent_signature.length < signature.length
          token_valid = false
          sent_signature = sent_signature.ljust(signature.length, "0000")
        elsif signature.length < sent_signature.length
          token_valid = false
          signature = signature.ljust(sent_signature.length, "0000")
        end
        token_valid = token_valid && Rack::Utils.secure_compare(signature, sent_signature)
      end

      token.update_expiry! if token_valid 

      token_valid ? success!(token.user) : fail!('strategies.authentication_token.failed')
    end

    private
    def parse_token
      @token = {id: nil, time: nil, signature: nil}
      auth_value = AuthorizationHeader.new(request.get_header("HTTP_AUTHORIZATION"))
      if auth_value.type != :token
        errors.add(:token_type, "Not \"TOKEN\" auth type")
        return
      end

      @token[:id] = parse_uuid(auth_value[:id]) if auth_value.has_param?(:id)
      @token[:raw_time] = auth_value[:time]
      @token[:time] = parse_time(auth_value[:time]) if auth_value.has_param?(:time)
      @token[:signature] = auth_value[:signature]
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

    def parse_time(datestring)
      begin
        Time.parse(datestring)
      rescue ArgumentError
        nil
      end
    end

    def token_id
      parse_token unless @token.present? && @token.has_key?(:id)
      @token[:id]
    end

    def token_time
      parse_token unless @token.present? && @token.has_key?(:time)
      @token[:time]
    end

    def token_signature
      parse_token unless @token.present? && @token.has_key?(:signature)
      @token[:signature]
    end

    def token_in_time_window?(time)
      return true if @@invalid_time_allowed
      oldest_time = (@@max_token_age + @@max_skew).seconds.ago
      newest_time = @@max_skew.seconds.from_now
      (newest_time > time) && (time > oldest_time)
    end

    def generate_signature(request, secret, raw_time)
      digest = OpenSSL::Digest::SHA256.new
      hmac = OpenSSL::HMAC.new(secret, digest)
      hmac << raw_time
      hmac << request.fullpath
      hmac << request.request_method
      while nil != data = request.body.read(1024)
        hmac << data
      end
      hmac.digest
    end

    def parse_signature(signature_string)
      if signature_string.ends_with?("=")
        Base64.decode64(signature_string)
      else
        [signature_string].pack("H*")
      end
    end

  public
    def self.InvalidTimeAllowed
      @@invalid_time_allowed
    end

    def self.InvalidTimeAllowed=(value)
      @@invalid_time_allowed = value == true
    end

    def self.UnsignedRequestsAllowed
      @@unsigned_requests_allowed
    end

    def self.UnsignedRequestsAllowed=(value)
      @@unsigned_requests_allowed = value == true
    end

    def self.MaxAllowedSkew=(value)
      int_value = value.to_i
      @@max_skew = int_value if int_value >= 0
    end

    def self.MaxAllowedSkew
      @@max_skew
    end

    def self.MaxTokenAge=(value)
      int_value = value.to_i
      @@max_token_age = int_value if int_value >= 0
    end

    def self.MaxTokenAge
      @@max_token_age
    end
  end
end