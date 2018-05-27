module ActsAsApiAuthable
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def copy_initializer
        copy_file 'acts_as_api_authable.rb', 'config/initializers/acts_as_api_authable.rb'
      end
    end
  end
end
