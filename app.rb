# frozen_string_literal: true

require 'sinatra'

require_relative 'meal'
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
    def user?
      @user != nil
    end
  end

  before do
    @user = nil

    auth = request.env['HTTP_AUTHORIZATION'].split(' ')

    if auth[0] == 'Bearer'
      @user = User.find_by_access_token(auth[1])
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
    if (user = User.authenticate(json['username'], json['password']))
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
    @user = nil
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
    meals = if @user.type == 'Admin'
              Meal.all
            else
              Meal.find_by_user(@user.id)
            end

    from = Time.parse(params[:from]) if params[:from]
    to = Time.parse(params[:to]) if params[:to]

    # :NOTE: 20190605 Terry: Inclusive of the to date.

    to = to + 24*60*60 if to

    now = Time.now
    from ||= now - 30 * 24 * 60 * 60
    to ||= now

    meals.select { |v| v.taken > from && v.taken < to}.to_json
  end

  post '/v1/meals', auth: 'user' do
    meal = Meal.new(request.body.read)
    meal.user_id = @user.id

    if meal.create
      meal.to_json
    else
      halt 500
    end
  end

  get '/v1/meals/:id', auth: 'user' do
    if (meal = Meal.get(params[:id]))
      if @user.type == 'Admin' || @user.id == meal.user_id
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
      if @user.type == 'Admin' || @user.id == meal.user_id
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
      if @user.type == 'Admin' || @user.id == meal.user_id
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
    response['Access-Control-Allow-Methods'] = 'GET, POST'
  end

  get '/v1/users', auth: 'user' do
    curr = @user

    users = if curr.is_user_manager?
              User.all
            else
              users = [curr]
            end

    users.to_json
  end

  post '/v1/users', auth: 'user' do
    content_type :json
    # :TODO: 20190605 Terry: DRY it up with /v1/signup"
    curr = @user
    if (!curr.nil? && curr.is_user_manager?)
      json = JSON.parse(request.body.read)
      if (user = User.signup(json['username'], json['password']))
        user.expected_daily_calories = json['expected_daily_calories']
        user.type = json['type']
        user.update
        user.to_json
      else
        halt 500
      end
    else
      halt 401
    end
  end

  options '/v1/users/:id' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'Content-Type,Authorization'
    response['Access-Control-Allow-Methods'] = 'GET, PUT, DELETE'
  end

  get '/v1/users/:id', auth: 'user' do
    if (user = User.get(params[:id]))
      curr = @user
      if curr.id == user.id || curr.is_user_manager?
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
      curr = @user
      if curr.id == user.id || curr.is_user_manager?
        vars = JSON.parse(request.body.read)
        user.username = vars['username']
        user.type = vars['type']
        user.expected_daily_calories = vars['expected_daily_calories']
        
        if !vars['password'].nil?
          user.init_password_salt_and_hash(vars['password'])
        end

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
      curr = @user
      # :NOTE: 20190605 Terry: Authenticated user cannot delete themselves. Must be User Manager role.
      if user.id != curr.id && curr.is_user_manager?
        user.destroy
      else
        halt 401
      end
    else
      halt 500
    end
  end
end
