ActsAsApiAuthable.Configure do |config|
  # the configured values are the defaults

  # Which types of auth to allow
  # :signature - an AWS like full signature with timestamp
  # :http_only_cookie - HTTP cookies that cannot be accessed by JS
  # in most cases http_only_cookie will be sufficient
  config.allowed_types = [:signature, :http_only_cookie]

  # SIGNED REQUEST SETTINGS
  # is an invalid time allowed?
  # will always be false in production!
  config.invalid_time_allowed = false
  # can a request have no signature at all?
  # will always be false in production!
  config.unsigned_requestes_allowed = false
  # how old can a signature timestamp be (in seconds) ?
  config.max_request_age = 60
  # how loose can the timing be (in seconds) ?
  config.max_clock_skew = 5

  # An array of models that we can authorize
  config.authable_models = []
end
