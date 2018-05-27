module ActsAsApiAuthable
  class FailureApp < ActionController::Metal
    def self.call(env)
      @respond ||= action(:respond)
      @respond.call(env)
    end

    def respond
      self.status = :unauthorized
      self.content_type  = "application/json"
      warden_errors = self.request.headers["warden.errors"]
      errors = {}
      return if warden_errors.blank?
      warden_errors.keys.each { |key| errors[key] = warden_errors[key] }
      self.response_body = errors.empty? ? nil : errors.to_json
    end
  end
end
