# frozen_string_literal: true

require 'sinatra'

require_relative 'meal'
require_relative 'user'
require_relative 'version'

# The application.
class App < Sinatra::Base
  use Rack::Session::Cookie, key: 'rack.session',
                             path: '/',
                             expire_after: 2_592_000, # In seconds
                             secret: ENV['RACK_SECRET']

  register do
    def auth(type)
      condition do
        halt 401 unless send("#{type}?")
      end
    end
  end

  helpers do
    def user?
      @user != nil
    end
  end

  before do
    if params[:token]
      user = User.find_by_access_token(params[:token])
      session[:uid] = user.id unless user.nil?
    end
    response['Access-Control-Allow-Origin'] = '*'
    @user = User.get(session[:uid])
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
    if (user = User.authenticate(json['username'], json['password']))
      session[:uid] = user.id
      return user.issue_access_token
    else
      halt 401
    end
  end

  options '/v1/signout' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'Content-Type'
    response['Access-Control-Allow-Methods'] = 'GET'
  end

  get '/v1/signout' do
    session[:uid] = nil
  end

  options '/v1/signup' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'Content-Type'
    response['Access-Control-Allow-Methods'] = 'POST'
  end

  post '/v1/signup' do
    content_type :json
    json = JSON.parse(request.body.read)
    if (user = User.signup(json['username'], json['password']))
      user.to_json
    else
      halt 500
    end
  end

  get '/v1/version' do
    { path: '/v1/meals', version: Version.string }.to_json
  end

  options '/v1/meals' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'Content-Type,Authorization'
    response['Access-Control-Allow-Methods'] = 'GET, POST'
  end

  options '/v1/meals/:id' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'Content-Type,Authorization'
    response['Access-Control-Allow-Methods'] = 'GET, PUT, DELETE'
  end

  get '/v1/meals', auth: 'user' do
    user = User.get(session[:uid])
    meals = if user.type == 'Admin'
              Meal.all
            else
              Meal.find_by_user(session[:uid])
            end
    now = Time.now
    
    from = Time.parse(params[:from]) if params[:from]
    to = Time.parse(params[:to]) if params[:to]

    from ||= now - 30 * 24 * 60 * 60
    to ||= now

    meals.select{|v| v.taken > from && v.taken < to}.to_json
  end

  post '/v1/meals', auth: 'user' do
    meal = Meal.new(request.body.read)
    meal.user_id = session[:uid]

    if meal.create
      meal.to_json
    else
      halt 500
    end
  end

  get '/v1/meals/:id', auth: 'user' do
    if (meal = Meal.get(params[:id]))
      user = User.get(session[:uid])
      if user.type == 'Admin' || user.id == meal.user_id
        meal.to_json
      else
        halt 401
      end
    else
      halt 500
    end
  end

  put '/v1/meals/:id', auth: 'user' do
    if (meal = Meal.get(params[:id]))
      user = User.get(session[:uid])
      if user.type == 'Admin' || user.id == meal.user_id
        vars = JSON.parse(request.body.read)
        meal.text = vars['text']
        meal.taken = Time.parse(vars['taken'])
        meal.calories = vars['calories']
        if meal.update
          meal.to_json
        else
          halt 500
        end
      else
        halt 401
      end
    else
      halt 500
    end
  end

  delete '/v1/meals/:id', auth: 'user' do
    if (meal = Meal.get(params[:id]))
      user = User.get(session[:uid])
      if user.type == 'Admin' || user.id == meal.user_id
        meal.destroy
      else
        halt 401
      end
    else
      halt 500
    end
  end

  options '/v1/users' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'Content-Type,Authorization'
    response['Access-Control-Allow-Methods'] = 'GET'
  end

  options '/v1/users/:id' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'Content-Type,Authorization'
    response['Access-Control-Allow-Methods'] = 'GET, PUT, DELETE'
  end

  get '/v1/users', auth: 'user' do
    user = User.get(session[:uid])

    users = if user.type == 'UserManager'
              User.all
            else
              users = [user]
            end

    users.to_json
  end

  get '/v1/users/:id', auth: 'user' do
    if (user = User.get(params[:id]))
      curr = User.get(session[:uid])
      if curr.id == user.id || curr.type == 'UserManager'
        user.to_json
      else
        halt 401
      end
    else
      halt 500
    end
  end

  put '/v1/users/:id', auth: 'user' do
    if (user = User.get(params[:id]))
      curr = User.get(session[:uid])
      if curr.id == user.id || curr.type == 'UserManager'
        vars = JSON.parse(request.body.read)
        user.expected_daily_calories = vars['expected_daily_calories']
        if user.update
          user.to_json
        else
          halt 500
        end
      else
        halt 401
      end
    else
      halt 500
    end
  end

  delete '/v1/users/:id', auth: 'user' do
    if (user = User.get(params[:id]))
      curr = User.get(session[:uid])
      if user.id = curr.id || user.type == 'UserManager'
        user.destroy
      else
        halt 401
      end
    else
      halt 500
    end
  end
end
