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
      print "I require no auth"

      render json: { nothing: "create" }
    end

    def destroy
      print "I require existing auth"

      render json: { nothing: "destroy" }
    end

  end
end
