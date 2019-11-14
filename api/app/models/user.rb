# frozen_string_literal: true
require 'securerandom'

# A User model.
class User
  include DataMapper::Resource

  property :id, Serial, index: true
  property :locator, Locator
  property :type, Discriminator
  property :email, String, length: 256, unique: true
  property :password_digext, String
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
  property :created_at, DateTime, required: true
  property :updated_at, DateTime, required: true
  property :deleted, ParanoidBoolean
  property :deleted_at, ParanoidDateTime

  belongs_to :account

  validates_uniqueness_of :email
  validates_presence_of :name, :email
  validates_format_of :email, as: :email_address

  def self.authenticate(email, password)
    user = User.first(email: email)
    if user && user.verified == false

    end
  end

  def admin?
    (@type == 'Admin')
  end

  def user_manager?
    ((@type == 'UserManager') || admin?)
  end

  def valid?
    user = User.first(email: @email) if @id.nil?
    (!@type.nil? && !@email.nil? && user.nil?)
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
