module ActsAsApiAuthable
  module Models
    module Token
      extend ActiveSupport::Concern

      included do
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

      def self.expired
        where("expires_at < ?", Time.now)
      end

      def self.remove_expired!
        expired.destroy_all
      end

    private
      def generate_id
        self.id = SecureRandom.uuid
      end

      def generate_secret
        self.secret = SecureRandom.random_bytes(32)
      end

      def set_expiry
        if self.device
          self.expires_at = SIGNATURE_EXPIRY.from_now
        else
          self.expires_at = HTTP_ONLY_EXPIRY.from_now
        end
      end
    end
  end
end
