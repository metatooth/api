# frozen_string_literal: true

# A User model.
class User
  include DataMapper::Resource

  property :id, Serial, index: true
  property :locator, UUID, unique: true 
  property :type, Discriminator
  property :email, String, length: 256, unique: true
  property :verified, Boolean, default: false
  property :access_token, APIKey
  property :access_expiry, DateTime
  property :failed_attempts, Integer, default: 0
  property :created_at, DateTime, required: true
  property :updated_at, DateTime, required: true
  property :deleted, ParanoidBoolean
  property :deleted_at, ParanoidDateTime

  def self.authenticate(email, password)
    user = User.find_by_email(email)
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
    user = User.find_by_email(@email) if @id.nil?
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
