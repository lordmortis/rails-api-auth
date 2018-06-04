module ActsAsApiAuthable
  module Util
    class Resource
      attr_reader :class_name, :singular
      attr_reader :path_names, :path, :path_prefix, :scoped_path,
        :sign_out_via
      attr_reader :format, :used_routes, :used_helpers, :failure_app, :router_name

      alias :name :singular

      def initialize(name, options)
        @path = (options[:path] || name).to_s
        @path_prefix = options[:path_prefix]
        @scoped_path = options[:as] ? "#{options[:as]}/#{name}" : name.to_s

        @singular = (options[:singular] || @scoped_path.tr('/', '_').singularize).to_sym
        @plural = (options[:plural] || @scoped_path.tr('/', '_').pluralize).to_sym
        @class_name = (options[:class_name] || name.to_s.classify).to_s
        ActiveSupport::Dependencies.reference(@class_name)
        @klass = ActiveSupport::Dependencies.constantize(@class_name)

        @sign_out_via = options[:sign_out_via] || :delete

        @format = options[:format]
        @router_name = options[:router_name]
      end

      def path_show
        "#{@singular}"
      end

      def path_create
        "#{@singular}"
      end

      def path_list
        "#{@plural}"
      end

      def path_delete
        "#{@singular}"
      end

      def controller
        "/acts_as_api_authable/controllers/token"
      end

    end
  end
end
