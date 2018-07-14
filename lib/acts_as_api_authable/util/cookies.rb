module ActsAsApiAuthable
  module Util
    class Cookies
      def self.Update(request, headers, token_record)
        headers["Set-Cookie"] = "secret=#{Rack::Utils.escape(Base64.encode64(token_record.secret).strip)}"
        headers["Set-Cookie"] += "; Expires=#{token_record.expires_at.gmtime.strftime("%a, %d-%b-%Y %H:%M:%S GMT") }"
        headers["Set-Cookie"] += "; domain=#{request.host}"
        headers["Set-Cookie"] += "; secure" if Rails.env.production?
        headers["Set-Cookie"] += "; HttpOnly"
      end

      def self.Destroy(request, headers)
        headers["Set-Cookie"] = "secret=\"\""
        headers["Set-Cookie"] += "; Max-Age=0"
        headers["Set-Cookie"] += "; domain=#{request.host}"
        headers["Set-Cookie"] += "; secure" if Rails.env.production?
        headers["Set-Cookie"] += "; HttpOnly"
      end

    end
  end
end
