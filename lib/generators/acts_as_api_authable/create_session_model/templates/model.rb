class _CamelName_ < ApplicationRecord
  include ActsAsApiAuthable::Models::Token
  # How long lived is a signature token?
  SIGNATURE_EXPIRY = 1.days
  # How long lived is an http only cookie?
  HTTP_ONLY_EXPIRY = 1.hour
end
