class ActsAsApiAuthable::Config
	attr_reader :unsigned_requests_allowed, :invalid_time_allowed,
		:unsigned_requests_allowed, :max_request_age, :max_clock_skew,
		:authable_models

	def initialize(attrs)
		@authable_models = []
		[
			:unsigned_requests_allowed, :invalid_time_allowed, 
			:unsigned_requests_allowed, :max_request_age,
			:max_clock_skew
		].each do |attr_name|
			instance_variable_set("@#{attr_name}", attrs[attr_name])
		end

		attrs.authable_models.each do |klass|
			valid = klass.is_a?(Class)
			if valid
				valid = klass.new.is_a? ActiveRecord::Base
			end

			if valid 
				@authable_models << klass
			else
				print "acts_as_api_authable: Warning: Invalid class type #{klass.to_s}\n"
			end
		end

		if @authable_models.empty?
			print "acts_as_api_authable: Error: No valid models supplied.\n"
			return
		end	
	end
end