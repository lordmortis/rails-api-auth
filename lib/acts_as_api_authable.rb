require 'warden'
require 'acts_as_api_authable/routes'
require 'acts_as_api_authable/version'

module ActsAsApiAuthable
  autoload :Config, 'acts_as_api_authable/config'

  module Controllers
    autoload :TokenController, 'acts_as_api_authable/controllers/token_controller'
  end

  module Models
    autoload :Token, 'acts_as_api_authable/models/token'
  end

  module Warden
    autoload :FailureApp,             'acts_as_api_authable/warden/failure_app'
    autoload :Strategies,             'acts_as_api_authable/warden/strategies'
    autoload :HttpOnlyCookieStrategy, 'acts_as_api_authable/warden/http_only_cookie_strategy'
    autoload :SignatureStrategy,      'acts_as_api_authable/warden/signature_strategy'
  end

  module Util
    autoload :Resource,             'acts_as_api_authable/util/resource'
    autoload :AuthorizationHeader,  'acts_as_api_authable/util/authorization_header'
  end

  mattr_accessor :router_name
  @@router_name = nil

  mattr_reader :resources
  @@resources = Hash.new

  def self.Configure
    config = OpenStruct.new({
      invalid_time_allowed: false,
      unsigned_requests_allowed: false,
      max_request_age: 60,
      max_clock_skew: 5,
      authable_models: [],
      allowed_types: [:signature, :http_only_cookie],
    })

    yield config

    ActsAsApiAuthable.Configuration = Config.new(config)

    return unless ActsAsApiAuthable.Configuration.valid?

    Rails.application.config.middleware.insert_before Rack::Head, ::Warden::Manager do |manager|
      manager.default_strategies ActsAsApiAuthable.Configuration.allowed_types
     manager.failure_app = ActsAsApiAuthable::Warden::FailureApp
    end

    if ActsAsApiAuthable.Configuration.allowed_types.include? :http_only_cookie
      Rails.application.config.middleware.insert_after ActionDispatch::Callbacks, ActionDispatch::Cookies
    end

  end

  def self.define_resource(resource, options)
    instance = ActsAsApiAuthable::Util::Resource.new(resource, options)
    @@resources[instance.name] = instance
  end

  def self.Configuration
    @config
  end

  def self.Configuration=(value)
    @config = value
  end
end

