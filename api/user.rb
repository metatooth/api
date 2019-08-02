# frozen_string_literal: true

require 'bcrypt'
require 'net/http'
require 'securerandom'

require_relative 'model'

# A User model.
class User < Model
  attr_accessor :id
  attr_accessor :type
  attr_accessor :email
  attr_accessor :firebase_id_token
  attr_accessor :verified
  attr_accessor :preferred_working_seconds_per_day
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

  def self.authenticate(email, password)
    user = User.find_by_email(email)
    if user && user.verified == false
      data = "{ \"idToken\": \"#{user.firebase_id_token}\" }"
      url = 'https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=AIzaSyAfqUev9Z8Xxs9j5-qLSJuENEvpBDFEDS0'
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
      request.body = data
      response = http.request(request)
      case response
      when Net::HTTPSuccess then

        body = JSON.parse(response.body)
        body['users'].each do |u|
          if u['localId'] == user.id
            user.verified = u['emailVerified']
            user.update
          end
        end
      else
        puts "ERROR at LOOKUP #{response.inspect}"
      end
    end

    data = "{ \"email\": \"#{email}\", \"password\": \"#{password}\", \"returnSecureToken\": \"true\" }"
    url = 'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyAfqUev9Z8Xxs9j5-qLSJuENEvpBDFEDS0'
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
    request.body = data
    response = http.request(request)
    case response
    when Net::HTTPSuccess then
      body = JSON.parse(response.body)

      user = User.get(body['localId'])

      if user && user.verified == true
        if user.failed_attempts != 0
          user.failed_attempts = 0
          user.update
        end
        return user
      end
    else
      puts "ERROR at AUTHENTICATION #{response.inspect}"
      puts response.body
      
      if user && user.verified == true
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

  def self.find_by_email(email)
    unless email.nil?
      enum = @@firestore.col('users')
                        .where('email', '==', email.downcase).get
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

  def self.signup(email, password)
    data = "{ \"email\": \"#{email}\", \"password\": \"#{password}\" }"
    url = 'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyAfqUev9Z8Xxs9j5-qLSJuENEvpBDFEDS0'
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
    request.body = data
    response = http.request(request)
    case response
    when Net::HTTPSuccess then
      body = JSON.parse(response.body)
      user = User.new(id: body['localId'], email: body['email'], firebase_id_token: body['idToken'])
      user.type = 'Admin'

      @@firestore.col('users').get do |_u|
        user.type = 'User'
        break
      end

      return user if user.create
    else
      puts "ERROR at SIGNUP #{response.inspect}"
      return nil
    end
  end

  def admin?
    (@type == 'Admin')
  end

  def create
    if valid? == true
      @created = @updated = Time.now
      @preferred_working_seconds_per_day = 21_600
      @failed_attempts = 0
      @verified = false
      doc_ref = @@firestore.col('users').doc(@id)
      doc_ref.set(type: @type, email: @email.downcase, firebase_id_token: @firebase_id_token,
                  verified: @verified, created: @created,
                  preferred_working_seconds_per_day: @preferred_working_seconds_per_day,
                  updated: @updated, failed_attempts: @failed_attempts)
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
    @email = snap.get('email')
    @verified = snap.get('verified')
    @firebase_id_token = snap.get('firebase_id_token')
    @preferred_working_seconds_per_day = snap.get('preferred_working_seconds_per_day').to_i
    @access_token = snap.get('access_token')
    @access_expiry = snap.get('access_expiry')
    @failed_attempts = snap.get('failed_attempts').to_i
    @created = snap.get('created')
    @updated = snap.get('updated')
  end

  def init_from_hash(params)
    @id = params[:id]
    @email = params[:email]
    @preferred_working_seconds_per_day = params[:preferred_working_seconds_per_day]
    @failed_attempts = params[:failed_attempts]
    @firebase_id_token = params[:firebase_id_token]
    @verified = params[:verified]
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
      id: @id, type: @type, email: @email, created: @created,
      preferred_working_seconds_per_day: @preferred_working_seconds_per_day,
      failed_attempts: @failed_attempts, updated: @updated,
      access_token: @access_token, access_expiry: @access_expiry
    }.to_json
  end

  def update
    if !@id.nil? && valid? == true
      @updated = Time.now
      resp = @@firestore.col('users').doc(@id).set(
        type: @type, email: @email.downcase, verified: @verified,
        firebase_id_token: @firebase_id_token,
        preferred_working_seconds_per_day: @preferred_working_seconds_per_day,
        failed_attempts: @failed_attempts,
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
