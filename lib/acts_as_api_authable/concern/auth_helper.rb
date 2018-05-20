module ActsAsApiAuthable
  extend ActiveSupport::Concern

  included do
    helper_method :warden, :signed_in?, :current_user

    prepend_before_action :authenticate!
  end

  def current_user
    warden.user
  end

  def signed_in?
    !warden.user.nil?
  end

  def warden
    request.env['warden']
  end

  def authenticate!
    warden.authenticate!
  end
end
