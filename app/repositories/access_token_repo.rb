# frozen_string_literal: true

class AccessTokenRepo < ROM::Repository[:access_tokens]
  def authenticate(id, token)
    at = access_tokens.by_pk(id).one!
    BCrypt::Password.new(at.token_digest).is_password?(token)
  end

  def by_id(id)
    access_tokens.by_pk(id).one!
  end

  def destroy(id)
    update_token = access_tokens.by_pk(id).command(:update)
    update_token.call(deleted: true, deleted_at: DateTime.now)
  end

  def generate(id)
    token = SecureRandom.hex
    update_token = access_tokens.by_pk(id).command(:update)
    update_token.call(token_digest: BCrypt::Password.create(token))
    token
  end

  def query(conditions)
    access_tokens
      .where(deleted: false)
      .where(conditions)
      .to_a
  end
end
