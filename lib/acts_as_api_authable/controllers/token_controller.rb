module ActsAsApiAuthable
  module Controllers
    class TokenController < ActionController::API
      before_action :authenticate!, except: [:create]

      def list
        log_action :list, nil, current_session

        render json: { nothing: "list" }
      end

      def show
        log_action :show, nil, current_session

        render json: token_serializer(current_session)
      end

      def create
        params = create_params

        errors = {}
        [:resource, :identifier, :password, :type].each do |param|
          unless params.has_key? param
            errors[param] = "parameter is missing"
          end
        end

        unless errors.empty?
          render json: errors.to_json, status: :bad_request
          return
        end

        type = params[:type].to_sym
        token_klass = params[:class_name].constantize
        unless ActsAsApiAuthable.Configuration.allowed_types.include? type
          render json: { error: "this site doesn't produce logins of type #{type}" }, status: :bad_request
          return
        end

        authable = nil

        begin
          res = params[:resource].capitalize.constantize
          if ActsAsApiAuthable.Configuration.authable_models.include? res
            authable = res.auth(params[:identifier], params[:password])
          end
        rescue NameError => e
        end

        if authable.present?
          token = token_klass.create(authable: authable, http_only: type == :http_only_cookie)
          log_action :create, token, nil
          self.send("create_render_#{type}", token)
        else
          render json: { error: "invalid identifier or password for the selected resource" }, status: :unauthorized
        end
      end

      def destroy
        log_action :destroy, nil, current_session

        current_session.destroy

        render json: { nothing: "destroy" }
      end

      private
      def token_serializer(token_record, include_secret = false)
        data = {
          id: Base64.encode64(token_record.uuid.raw).strip,
          created_at: token_record.created_at,
          expires_at: token_record.expires_at,
        }
        data[:identifier] = token_record.authable.identifier if token_record.has_identifier?
        data[:permissions] = token_record.permissions if token_record.has_permissions?
        data[:device_name] = token_record.device_name unless token_record.http_only?
        data[:secret] = Base64.encode64(token_record.secret).strip if include_secret
        return data
      end

      def create_render_http_only_cookie(token_record)
        ActsAsApiAuthable::Util::Cookies.Update(request, response, token_record)
        render json: token_serializer(token_record)
      end

      def create_render_signature(token_record)
        render json: token_serializer(token_record, true)
      end

      def create_params
        params.permit [:resource, :identifier, :password, :type, :class_name]
      end

      def log_action(type, session, current_session)
        token_klass = params[:class_name].constantize
        method_name = "log_#{type.to_s}"
        return unless token_klass.respond_to? method_name
        token_klass.send(method_name, session, request, current_session)
      end

    end
  end
end
