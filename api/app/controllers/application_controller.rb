# frozen_string_literal: true

require 'sinatra'

require_relative '../models/user'

require_relative '../../version'
require_relative 'authentication'

# The application.
class ApplicationController < Sinatra::Base
  include Authentication

  helpers do
    def admin?
      user? && @user.admin?
    end

    def user?
      @user != nil
    end

    def user_manager?
      user? && @user.user_manager?
    end
  end

  before do
    @user = nil

    validate_auth_scheme
    authenticate_client
      
    response['Access-Control-Allow-Origin'] = '*'
  end

  get '/' do
    'OK'
  end

  options '/v1/signin' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'Content-Type'
    response['Access-Control-Allow-Methods'] = 'POST'
  end

  post '/v1/signin' do
    response['Access-Control-Allow-Origin'] = '*'

    json = JSON.parse(request.body.read)
    user = User.authenticate(json['email'], json['password'])
    token = ''
    if user
      token = user.issue_access_token
    else
      halt 401
    end
    token
  end

  options '/v1/signout' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'Content-Type'
    response['Access-Control-Allow-Methods'] = 'GET'
  end

  get '/v1/signout' do
    @user = nil
  end

  options '/v1/signup' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'Content-Type'
    response['Access-Control-Allow-Methods'] = 'POST'
  end

  post '/v1/signup' do
    json = JSON.parse(request.body.read)
    if (user = User.signup(json['email'], json['password']))

      data = "{ \"requestType\": \"VERIFY_EMAIL\", \"idToken\": \"#{user.firebase_id_token}\" }"
      url = 'https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=AIzaSyAfqUev9Z8Xxs9j5-qLSJuENEvpBDFEDS0'
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
  
      request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
      request.body = data
      response = http.request(request)

      case response
      when Net::HTTPSuccess then
        user.to_json       
      else
        puts "ERROR at VERIFY_EMAIL #{response}"
        halt 500
      end
    else
      halt 500
    end
  end

  options '/v1/trackers' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'Content-Type'
    response['Access-Control-Allow-Methods'] = 'POST'
  end

  get '/v1/version' do
    { version: Version.string }.to_json
  end
end
