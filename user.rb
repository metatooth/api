# frozen_string_literal: true

require 'bcrypt'
require_relative 'model'

# A User model.
class User < Model
  attr_accessor :id
  attr_accessor :type
  attr_accessor :username
  attr_accessor :password_salt
  attr_accessor :password_hash
  attr_accessor :created
  attr_accessor :updated

  def self.authenticate(username, password)
    user = User.find_by_username(username)
    check_hash = BCrypt::Engine.hash_secret(password, user.password_salt)
    return user if user && user.password_hash == check_hash

    nil
  end

  def self.find_by_username(username)
    enum = @@firestore.col('users').where('username', '==', username).get
    enum.each do |doc|
      return User.new(doc)
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
    return user if user.create

    nil
  end

  def create
    if @id.nil? && valid? == true
      doc_ref = @@firestore.col('users').doc
      doc_ref.set(type: @type, username: @username,
                  password_salt: @password_salt, password_hash: @password_hash,
                  created: Time.now, updated: Time.now)
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
    @username = snap.get('username')
    @password_salt = snap.get('password_salt')
    @password_hash = snap.get('password_hash')
    @created = snap.get('created')
    @updated = snap.get('updated')
  end

  def init_from_hash(params)
    @username = params[:username]
    @password_salt = BCrypt::Engine.generate_salt
    @password_hash =
      BCrypt::Engine.hash_secret(params[:password], @password_salt)
  end

  def initialize(params)
    @type = 'User'
    if params.class == Google::Cloud::Firestore::DocumentSnapshot
      init_from_snap(params)
    elsif params.class == Hash
      init_from_hash(params)
    end
  end

  def update
    if @id && valid?
      resp = @@firestore.col('users').doc(@id).set(
        type: @type,
        username: @username,
        updated: Time.now
      )
    end
    true if resp
  end

  def valid?
    user = User.find_by_username(@username)
    @type && @username && !user
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
