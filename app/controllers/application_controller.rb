# frozen_string_literal: true

require 'sinatra'

require_relative '../models/user'

require_relative '../../version'
require_relative 'authentication'

# The application.
class ApplicationController < Sinatra::Base
  include Authentication

  register do
    def auth(_type)
      condition do
        halt 401 unless send(type?.to_s)
      end
    end
  end

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
    target = request.path_info.split('/')[1]
    pass if %w[user_confirmations password_resets].include?(target)

    @user = nil

    validate_auth_scheme
    authenticate_client

    response['Access-Control-Allow-Origin'] = '*'
  end

  error do
    resource_not_found
  end

  get '/' do
    'OK'
  end

  options '/api/signin' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'Content-Type'
    response['Access-Control-Allow-Methods'] = 'POST'
  end

  post '/api/signin' do
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

  options '/api/signout' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'Content-Type'
    response['Access-Control-Allow-Methods'] = 'GET'
  end

  get '/api/signout' do
    @user = nil
  end

  options '/api/signup' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'Content-Type'
    response['Access-Control-Allow-Methods'] = 'POST'
  end

  post '/api/signup' do
  end

  get '/api/version' do
    { version: Version.string }.to_json
  end

  protected

  def resource_not_found
    halt(404)
  end

  def unprocessable_entity!(resource)
    halt(422, {
      error: {
        message: "Invalid parameters for resource #{resource.class}.",
        invalid_params: resource.errors
      }
    }.to_json)
  end
end
