require "acts_as_api_authable/railtie"
require "acts_as_api_authable/config"

module ActsAsApiAuthable
  def self.Configure
    config = OpenStruct.new({
      invalid_time_allowed: false,
      unsigned_requests_allowed: false,
      max_request_age: 60,
      max_clock_skew: 5,
      authable_models: [],
      allowed_types: [:signature, :http_only_cookie],
      session_model: Session,
    })

    yield config

    ActsAsApiAuthable.Configuration = Config.new(config)
  end

  def self.Configuration
    @config
  end

  def self.Configuration=(value)
    @config = value
  end
end

