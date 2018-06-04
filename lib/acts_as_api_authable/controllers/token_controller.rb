module ActsAsApiAuthable
  module Controllers
    class TokenController < ActionController::API

      def list
        print "I require existing auth"
        print "Show"

        render json: { nothing: "list" }
      end

      def show
        print "I require existing auth"

        render json: { nothing: "show" }
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
          self.send("create_render_#{type}", token)
        else
          render json: { error: "invalid identifier or password for the selected resource" }, status: :unauthorized
        end
      end

      def destroy
        print "I require existing auth"

        render json: { nothing: "destroy" }
      end

      private
      def token_serializer(token_record, include_secret = false)
        data = {
          id: Base64.encode64(token_record.uuid.raw).strip,
          created_at: token_record.created_at,
          expires_at: token_record.expires_at,
        }
        data[:permissions] = token_record.permissions if token_record.has_permissions?
        data[:device_name] = token_record.device_name unless token_record.http_only?
        data[:secret] = Base64.encode64(token_record.secret).strip if include_secret
        return data
      end

      def create_render_http_only_cookie(token_record)
        response.set_cookie(:secret, {
          value: Base64.encode64(token_record.secret).strip,
          expires: token_record.expires_at,
          domain: request.host,
          secure: Rails.env.production?,
          httponly: true
        })
        render json: token_serializer(token_record)
      end

      def create_render_signature(token_record)
        render json: token_serializer(token_record, true)
      end

      def create_params
        params.permit [:resource, :identifier, :password, :type, :class_name]
      end

    end
  end
end
