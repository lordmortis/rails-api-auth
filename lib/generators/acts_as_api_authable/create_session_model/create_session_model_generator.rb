module ActsAsApiAuthable
  module Generators
    class CreateSessionModelGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      argument :model_name, :default => "Session"


      def convert_model_name
        @camel = model_name.camelize
        @snake_case = model_name.underscore
      end

      def bail_if_model_or_migration_exists
        abort("Model exists at #{model_path} - bailing") if model_exists?
        abort("Migration exists at #{migration_path} - bailing") if migration_exists?
      end

      def make_model
        create_file model_path do
          File.read(find_in_source_paths('model.rb')).gsub("_CamelName_", @camel)
        end
      end

      def make_migration
        filename = "#{Time.now.strftime("%Y%m%d%H%M%S")}_create_#{@snake_case}.rb"
        dst = File.join("db", "migrate", filename)

        create_file dst do
          data = File.read(find_in_source_paths('migration.rb'))
          data.gsub!("_CamelName_", @camel)
          data.gsub!("_snake_case_", @snake_case.pluralize)
          data.gsub!("_RAILS_VERSION_", Rails.version.split(".")[0..1].join('.'))
          data
        end
      end

      private

      def model_exists?
        File.exist?(File.join(Rails.root, model_path))
      end

      def migration_exists?
        migration_path.present?
      end

      def model_path
        @model_path ||= File.join("app", "models", "#{@snake_case}.rb")
      end

      def migration_path
        @migration_path ||= find_migration_path
      end

      def find_migration_path
        path = File.join(Rails.root, "db", "migrate")
        Dir.glob("#{path}/[0-9]*_*.rb").grep(/\d+_create_#{@snake_case}.rb$/).first
      end
    end
  end
end
