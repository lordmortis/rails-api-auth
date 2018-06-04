module ActsAsApiAuthable
  module Warden
    module Strategies
      def self.Setup
        return if @setup_complete
        return unless ActsAsApiAuthable.Configuration.valid
        config = ActsAsApiAuthable.Configuration
        config.allowed_types.each do |type|
          self.send("setup_#{type}")
        end

        @setup_complete = true
      end

      def self.setup_signature
        ::Warden::Strategies.add(:signature, ActsAsApiAuthable::Warden::SignatureStrategy)
      end

      def self.setup_http_only_cookie
        ::Warden::Strategies.add(:http_only_cookie, ActsAsApiAuthable::Warden::HttpOnlyCookieStrategy)
      end
    end
  end
end
