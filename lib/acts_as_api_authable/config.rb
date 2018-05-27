class ActsAsApiAuthable::Config
	attr_reader :max_request_age, :max_clock_skew,
		:authable_models, :allowed_types, :valid

	def initialize(attrs)
		@valid = true
		@authable_models = []
		@allowed_types = []
		[
			:unsigned_requests_allowed, :invalid_time_allowed,
			:max_request_age, :max_clock_skew,
		].each do |attr_name|
			instance_variable_set("@#{attr_name}", attrs[attr_name])
		end

		attrs.authable_models.each do |klass|
			valid = klass.is_a?(Class)
			if valid
				begin # need this in case migrations/setup are being run
					valid = klass.new.is_a? ActiveRecord::Base
				rescue
				end
			end

			if valid
				@authable_models << klass
			else
				print "acts_as_api_authable: Warning: Invalid class type #{klass.to_s}\n"
			end
		end

		if @authable_models.empty?
			print "acts_as_api_authable: Error: No valid models supplied.\n"
			@valid = false
		end

		if attrs.allowed_types.is_a? Symbol
			if valid_auth_type? attrs.allowed_types
				@allowed_types << attrs.allowed_types
			end
		elsif attrs.allowed_types.is_a? Array
			attrs.allowed_types.each do |type|
				if valid_auth_type? type
					@allowed_types << type
				end
			end
		end

		if @allowed_types.empty?
			print "No allowed auth types"
			@valid = false
		end

=begin
		if attrs.session_model.blank?
			print "No Session model specified"
			@valid = false
		else
			valid = attrs.session_model.is_a?(Class)
			@session_model = attrs.session_model if (valid)
		end
=end
	end

	def unsigned_requests_allowed
		Rails.env.production? ? true : @unsigned_requests_allowed
	end

	def invalid_time_allowed
		Rails.env.production? ? true : @invalid_time_allowed
	end

	def valid?
		valid
	end

private

	def valid_auth_type?(type)
		[:signature, :http_only_cookie].include? type
	end
end
