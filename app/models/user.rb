# frozen_string_literal: true

# A User model.
class User
  include DataMapper::Resource

  belongs_to :account
  has n, :access_tokens

  property :id, Serial, index: true
  property :locator, Locator
  property :type, Discriminator
  property :email, String, length: 256, index: true, unique: true
  property :password_digest, String, length: 256
  property :name, String, length: 256
  property :last_logged_in_at, DateTime
  property :confirmation_token, APIKey, unique: true
  property :confirmation_redirect_url, String
  property :confirmed_at, DateTime
  property :confirmation_sent_at, DateTime
  property :reset_password_token, APIKey
  property :reset_password_redirect_url, String
  property :reset_password_sent_at, DateTime
  property :failed_attempts, Integer, default: 0
  property :created_at, DateTime
  property :updated_at, DateTime
  property :deleted, ParanoidBoolean, default: false
  property :deleted_at, ParanoidDateTime

  validates_uniqueness_of :email
  validates_presence_of :name, :email
  validates_format_of :email, as: :email_address

  before :valid?, :downcase_email

  def admin?
    (@type == 'Admin')
  end

  def authenticate(_password)
    return false if password_digest.nil?

    BCrypt::Password.new(password_digest).is_password?(_password) && self
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
    ((@type == 'UserManager') || admin?)
  end

  private

  def generate_confirmation_token
    self.confirmation_token = SecureRandom.hex
  end

  def downcase_email
    self.email = email.downcase if email
  end
end

# UserManager role can CRUD user records
class UserManager < User
  def initialize(params)
    super(params)
    @type = 'UserManager'
  end
end

# Admin role can CRUD all records
class Admin < UserManager
  def initialize(params)
    super(params)
    @type = 'Admin'
  end
end
