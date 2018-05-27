module ActsAsApiAuthable
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
      require "acts_as_api_authable/strategies/signature"
      Warden::Strategies.add(:signature, ActsAsApiAuthable::Strategies::Signature)
    end

    def self.setup_http_only_cookie
      require "acts_as_api_authable/strategies/http_only_cookie"
      Warden::Strategies.add(:http_only_cookie, ActsAsApiAuthable::Strategies::HttpOnlyCookie)
    end
  end
end
