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
    @user = User.get(session[:uid])
  end

  get '/' do
    'Hello, anonymous.'
  end

  post '/signin' do
    json = JSON.parse(request.body.read)
    if (user = User.authenticate(json['username'], json['password']))
      session[:uid] = user.id
    else
      halt 401
    end
  end

  get '/signout' do
    session[:uid] = nil
  end

  post '/signup' do
    content_type :json
    json = JSON.parse(request.body.read)
    if (user = User.signup(json['username'], json['password']))
      user.to_json
    else
      halt 500
    end
  end

  get '/version' do
    { path: '/v1/meals', version: Version.string }.to_json
  end

  get '/v1/meals', auth: 'user' do
    user = User.get(session[:uid])
    meals = if user.type == 'Admin'
              Meal.all
            else
              Meal.find_by_user(session[:uid])
            end

    meals
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
        meal.taken = vars['taken']
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
end
