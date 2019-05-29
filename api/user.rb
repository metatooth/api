# frozen_string_literal: true

require 'bcrypt'
require_relative 'model'

# A User model.
class User < Model
  attr_accessor :id
  attr_accessor :username
  attr_accessor :password_salt
  attr_accessor :password_hash
  attr_accessor :created
  attr_accessor :updated

  def self.authenticate(username, password)
    user = User.find_by_username(username)
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      return user
    else
      return nil
    end
  end

  def self.find_by_username(username)
    enum = @@firestore.col('users').where('username', '==', username).get
    enum.each do |doc|
        return User.new(doc)
    end
    return nil
  end

  def self.get(id)
    user_snap = @@firestore.col('users').doc(id).get
    user = User.new(user_snap) if user_snap.exists?
    user
  end

  def self.signup(username, password)
    user = User.new({ username: username, password: password })
    if user.create
        return user
    else
        return nil
    end
  end

  def create
    if @id.nil? && true == valid?
        doc_ref = @@firestore.col('users').doc
        doc_ref.set({username: @username,
            password_salt: @password_salt,
            password_hash: @password_hash,
            created: Time.now,
            updated: Time.now})
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
    @password_hash = BCrypt::Engine.hash_secret(params[:password], @password_salt)
  end   

  def initialize(params)
    if params.class == Google::Cloud::Firestore::DocumentSnapshot
        init_from_snap(params)
    elsif params.class == Hash
        init_from_hash(params)
    end
  end

  def update
    throw "User::update not implemented."
  end

  def valid?
    user = User.find_by_username(@username)
    @username && !user
  end

end
