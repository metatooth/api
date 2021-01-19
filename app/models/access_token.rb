# frozen_string_literal: true

# Access Token allows User access to API
class AccessToken < ROM::Struct
  def authenticate(unencrypted_token)
    BCrypt::Password.new(token_digest).is_password?(unencrypted_token)
  end

  def expired?
    created_at + 14 < DateTime.now
  end
end
