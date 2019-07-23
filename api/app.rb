# frozen_string_literal: true

require 'sinatra'

require_relative 'user'
require_relative 'version'

# The application.
class App < Sinatra::Base

  register do
    def auth(type)
      condition do
        halt 401 unless send("#{type}?")
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
    @user = nil

    header = request.env['HTTP_AUTHORIZATION']
    if header
      auth = header.split(' ')
      @user = User.find_by_access_token(auth[1]) if auth[0] == 'Bearer'
    end
    response['Access-Control-Allow-Origin'] = '*'
  end

  get '/' do
    'Hello, anonymous.'
  end

  options '/v1/signin' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'Content-Type'
    response['Access-Control-Allow-Methods'] = 'POST'
  end

  post '/v1/signin' do
    response['Access-Control-Allow-Origin'] = '*'

    json = JSON.parse(request.body.read)
    user = User.authenticate(json['username'], json['password'])
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
    if (user = User.signup(json['username'], json['password']))
      user.to_json
    else
      halt 500
    end
  end

  get '/v1/version' do
    { path: '/v1/tasks', version: Version.string }.to_json
  end
end

require_relative 'tasks'
require_relative 'users'
