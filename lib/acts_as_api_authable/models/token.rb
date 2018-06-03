module ActsAsApiAuthable
  module Models
    module Token
      extend ActiveSupport::Concern

      included do
        ActsAsApiAuthable::Strategies.Setup

        belongs_to :authable, polymorphic: true

        before_create :generate_id, :generate_secret, :set_expiry
      end

      def uuid
        @uuid ||= UUIDTools::UUID.parse(self.id)
      end

      def expired?
        expires_at < Time.now
      end

      def update_expiry!
        set_expiry
        save!
      end

      def has_permissions?
        return false if authable.blank?
        authable.respond_to? :permissions
      end

      def permissions
        return nil if authable.blank?
        return nil unless authable.respond_to? :permissions
        authable.permissions
      end

      def self.expired
        where("expires_at < ?", Time.now)
      end

      def self.remove_expired!
        expired.destroy_all
      end

      def self.create_for_resource!(authable)
        self.create(authable: authable)
      end

    private
      def generate_id
        self.id = SecureRandom.uuid
      end

      def generate_secret
        self.secret = SecureRandom.random_bytes(32)
      end

      def set_expiry
        if self.http_only
          self.expires_at = self.class::HTTP_ONLY_EXPIRY.from_now
        else
          self.expires_at = self.class::SIGNATURE_EXPIRY.from_now
        end
      end
    end
  end
end
