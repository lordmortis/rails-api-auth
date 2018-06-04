module ActsAsApiAuthable
  module Controllers
    module Helpers
      extend ActiveSupport::Concern

      included do
        helper_method :warden, :signed_in?, :current_session, :current_authable, :current_user, :authenticate!
      end

      def current_user
        current_authable
      end

      def current_authable
        return nil if warden.user.blank?
        warden.user.authable
      end

      def current_session
        warden.user
      end

      def user_signed_in?
        !warden.user.nil?
      end

      def warden
        request.env['warden']
      end

      def authenticate!
        warden.authenticate!
      end
    end
  end
end
