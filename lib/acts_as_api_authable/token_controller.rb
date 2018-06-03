module ActsAsApiAuthable
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
      [:resource, :identifier, :password].each do |param|
        unless params.has_key? param
          errors[param] = "parameter is missing"
        end
      end

      unless errors.empty?
        render json: errors.to_json, status: :bad_request
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

      if authable != nil
        render json: { authable: "woot" }
      else
        render json: nil, status: :unauthorized
      end
    end

    def destroy
      print "I require existing auth"

      render json: { nothing: "destroy" }
    end

    private

    def create_params
      params.permit [:resource, :identifier, :password]
    end

  end
end
