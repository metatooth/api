# frozen_string_literal: true

require 'bcrypt'
require 'securerandom'

require_relative 'model'

# A User model.
class User < Model
  attr_accessor :id
  attr_accessor :type
  attr_accessor :username
  attr_accessor :preferred_working_seconds_per_day
  attr_accessor :password_salt
  attr_accessor :password_hash
  attr_accessor :access_token
  attr_accessor :access_expiry
  attr_accessor :failed_attempts
  attr_accessor :created
  attr_accessor :updated

  def self.all
    users = []
    users_ref = @@firestore.col('users')
    users_ref.get do |user|
      users << User.new(user)
    end
    users
  end

  def self.authenticate(username, password)
    user = User.find_by_username(username)
    if user && user.failed_attempts < 3
      check_hash = BCrypt::Engine.hash_secret(password, user.password_salt)
      if user.password_hash == check_hash
        if user.failed_attempts != 0
          user.failed_attempts = 0
          user.update
        end
        return user
      else
        user.failed_attempts = user.failed_attempts + 1
        user.update
      end
    end

    nil
  end

  def self.find_by_access_token(token)
    enum = @@firestore.col('users').where('access_token', '==', token).get
    enum.each do |doc|
      user = User.new(doc)
      return user if user.access_expiry > Time.now
    end
    nil
  end

  def self.find_by_username(username)
    unless username.nil?
      enum = @@firestore.col('users')
                        .where('username', '==', username.downcase).get
      enum.each do |doc|
        return User.new(doc)
      end
    end
    nil
  end

  def self.get(id)
    user_snap = @@firestore.col('users').doc(id).get
    user = User.new(user_snap) if user_snap.exists?

    user
  end

  def self.signup(username, password)
    user = User.new(username: username, password: password)
    user.type = 'Admin'

    @@firestore.col('users').get do |_u|
      user.type = 'User'
      break
    end

    return user if user.create

    nil
  end

  def admin?
    (@type == 'Admin')
  end

  def create
    if @id.nil? && valid? == true
      doc_ref = @@firestore.col('users').doc
      @created = @updated = Time.now
      @preferred_working_seconds_per_day = 21_600
      @failed_attempts = 0
      doc_ref.set(type: @type, username: @username.downcase, created: @created,
                  preferred_working_seconds_per_day: @preferred_working_seconds_per_day,
                  password_salt: @password_salt, password_hash: @password_hash,
                  updated: @updated, failed_attempts: @failed_attempts)
      @id = doc_ref.document_id
      issue_access_token
    end
    true if @id
  end

  def destroy
    doc_ref = @@firestore.col('users').doc(@id)
    doc_ref.delete
  end

  def init_from_snap(snap)
    @id = snap.document_id
    @type = snap.get('type')
    @username = snap.get('username')
    @preferred_working_seconds_per_day = snap.get('preferred_working_seconds_per_day').to_i
    @password_salt = snap.get('password_salt')
    @password_hash = snap.get('password_hash')
    @access_token = snap.get('access_token')
    @access_expiry = snap.get('access_expiry')
    @failed_attempts = snap.get('failed_attempts').to_i
    @created = snap.get('created')
    @updated = snap.get('updated')
  end

  def init_from_hash(params)
    @username = params[:username]
    @preferred_working_seconds_per_day = params[:preferred_working_seconds_per_day]
    @failed_attempts = params[:failed_attempts]
    init_password_salt_and_hash(params[:password])
  end

  def init_password_salt_and_hash(password)
    @password_salt = BCrypt::Engine.generate_salt
    @password_hash = BCrypt::Engine.hash_secret(password, @password_salt)
  end

  def initialize(params)
    if params.class == Google::Cloud::Firestore::DocumentSnapshot
      init_from_snap(params)
    elsif params.class == Hash
      init_from_hash(params)
    end
  end

  def issue_access_token
    @access_token = SecureRandom.hex(32)
    @access_expiry = Time.now + 30 * 24 * 60 * 60
    return @access_token if update

    nil
  end

  def to_json(*_args)
    {
      id: @id, type: @type, username: @username, created: @created,
      preferred_working_seconds_per_day: @preferred_working_seconds_per_day,
      failed_attempts: @failed_attempts, updated: @updated,
      access_token: @access_token, access_expiry: @access_expiry
    }.to_json
  end

  def update
    if !@id.nil? && valid? == true
      @updated = Time.now
      resp = @@firestore.col('users').doc(@id).set(
        type: @type, username: @username.downcase,
        preferred_working_seconds_per_day: @preferred_working_seconds_per_day,
        failed_attempts: @failed_attempts,
        password_hash: @password_hash, password_salt: @password_salt,
        access_token: @access_token, access_expiry: @access_expiry,
        created: @created, updated: @updated
      )
    end
    true if resp
  end

  def user_manager?
    ((@type == 'UserManager') || admin?)
  end

  def valid?
    user = User.find_by_username(@username) if @id.nil?
    (!@type.nil? && !@username.nil? && user.nil?)
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
