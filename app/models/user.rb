# frozen_string_literal: true

# A User model.
class User < ROM::Struct
  def admin?
    false
  end

  def authenticate(password)
    return false if password_digest.nil?

    BCrypt::Password.new(password_digest).is_password?(password) && self
  end

  def confirm
    update(confirmation_token: nil, confirmed_at: DateTime.now)
  end

  def destroy
    update({ deleted: true, deleted_at: DateTime.now })
  end

  def init_password_reset(redirect_url)
    update(reset_password_token: SecureRandom.hex,
           reset_password_sent_at: DateTime.now,
           reset_password_redirect_url: redirect_url)
  end

  def complete_password_reset(password)
    update(password: password,
           reset_password_token: nil,
           reset_password_sent_at: nil,
           reset_password_redirect_url: nil)
  end

  def password=(new_password)
    if new_password.nil?
      self.password_digest = nil
    elsif !new_password.empty?
      self.password_digest = BCrypt::Password.create(new_password)
    end
  end

  def password_confirmation=(confirm_password); end

  def user_manager?
    false
  end

  private

  def generate_confirmation_token
    self.confirmation_token = SecureRandom.hex
  end

  def downcase_email
    self.email = email.downcase if email
  end

  def set_name
    self.name = email.split('@')[0] if name.nil? && email
  end
end

# UserManager role can CRUD user records
class UserManager < User
  def user_manager?
    true
  end
end

# Admin role can CRUD all records
class Admin < UserManager
  def admin?
    true
  end
end
