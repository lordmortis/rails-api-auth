$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "acts_as_api_authable/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "acts_as_api_authable"
  s.version     = ActsAsApiAuthable::VERSION
  s.platform    = Gem::Platform::RUBY
  s.licenses    = ["MIT"]
  s.authors     = ["Brendan Ragan"]
  s.email       = ["lordmortis@gmail.com"]
  s.homepage    = "https://github.com/lordmortis/acts_as_api_authable"
  s.summary     = "Secure rails API authentication"
  s.description = "Authentication for a rails api app using both HTTP_ONLY cookies and full-blown signature signing"
  s.require_paths = ["lib"]
  s.required_ruby_version = '>= 2.4.0'

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.2.0"
  s.add_dependency "warden", "~> 1.2.0"
  s.add_dependency "uuidtools", "~> 2.1.5"
end
