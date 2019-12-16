# frozen_string_literal: true

require 'bcrypt'

# Access Token allows User access to API
class AccessToken
  include DataMapper::Resource
  belongs_to :user
  belongs_to :api_key

  property :id, Serial
  property :token_digest, String, length: 256
  property :accessed_at, DateTime
  property :created_at, DateTime
  property :updated_at, DateTime
  property :deleted, ParanoidBoolean, default: false, lazy: false
  property :deleted_at, ParanoidDateTime

  def authenticate(unencrypted_token)
    BCrypt::Password.new(token_digest).is_password?(unencrypted_token)
  end

  def expired?
    created_at + 14 < DateTime.now
  end

  def generate_token
    token = SecureRandom.hex
    update(token_digest: BCrypt::Password.create(token))
    token
  end
end
