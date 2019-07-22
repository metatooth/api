# frozen_string_literal: true

require 'bcrypt'
require 'securerandom'

require_relative 'model'

# A User model.
class User < Model
  attr_accessor :id
  attr_accessor :type
  attr_accessor :username
  attr_accessor :expected_daily_calories
  attr_accessor :password_salt
  attr_accessor :password_hash
  attr_accessor :access_token
  attr_accessor :access_expiry
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
    if user
      check_hash = BCrypt::Engine.hash_secret(password, user.password_salt)
      return user if user.password_hash == check_hash
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
                        .where('username', '==', username.upcase).get
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
    user.type = 'User'
    return user if user.create

    nil
  end

  def create
    if @id.nil? && valid? == true
      issue_access_token
      doc_ref = @@firestore.col('users').doc
      doc_ref.set(type: @type, username: @username.upcase, created: Time.now,
                  expected_daily_calories: 2000, password_salt: @password_salt,
                  password_hash: @password_hash, updated: Time.now,
                  access_token: @access_token, access_expiry: @access_expiry)
      @id = doc_ref.document_id
    end
    true if @id
  end

  def destroy
    doc_ref = @@firestore.col('users').doc(@id)
    true if doc_ref.delete
  end

  def init_from_snap(snap)
    @id = snap.document_id
    @type = snap.get('type')
    @username = snap.get('username')
    @expected_daily_calories = snap.get('expected_daily_calories')
    @password_salt = snap.get('password_salt')
    @password_hash = snap.get('password_hash')
    @access_token = snap.get('access_token')
    @access_expiry = snap.get('access_expiry')
    @created = snap.get('created')
    @updated = snap.get('updated')
  end

  def init_from_hash(params)
    @username = params[:username]
    @expected_daily_calories = params[:expected_daily_calories]
    init_password_salt_and_hash(params[:password])
  end

  def init_password_salt_and_hash(password)
    @password_salt = BCrypt::Engine.generate_salt
    @password_hash =
      BCrypt::Engine.hash_secret(password, @password_salt)
  end

  def initialize(params)
    if params.class == Google::Cloud::Firestore::DocumentSnapshot
      init_from_snap(params)
    elsif params.class == Hash
      init_from_hash(params)
    end
  end

  def admin?
    (@type == 'Admin')
  end

  def user_manager?
    ((@type == 'UserManager') || admin?)
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
      expected_daily_calories: @expected_daily_calories, updated: @updated,
      access_token: @access_token, access_expiry: @access_expiry
    }.to_json
  end

  def update
    if !@id.nil? && valid? == true
      resp = @@firestore.col('users').doc(@id).set(
        type: @type, username: @username.upcase,
        expected_daily_calories: @expected_daily_calories,
        password_hash: @password_hash, password_salt: @password_salt,
        access_token: @access_token, access_expiry: @access_expiry,
        created: @created, updated: Time.now
      )
    end
    true if resp
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