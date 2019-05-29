# frozen_string_literal: true

require 'sinatra'

require_relative 'meal'
require_relative 'user'
require_relative 'version'

class App < Sinatra::Base
    use Rack::Session::Cookie, :key => 'rack.session',
        :path => '/',
        :expire_after => 2592000, # In seconds
        :secret => ENV['RACK_SECRET']

  register do
    def auth(type)
      condition do
        halt 401 unless send("is_#{type}?")
      end
    end
  end

  helpers do
    def is_user?
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
    body_str = request.body.read
    json = JSON.parse(body_str)
    if user = User.authenticate(json['username'], json['password'])
        session[:uid] = user.id
    end
  end

  get '/signout' do
    session[:uid] = nil
  end

  post '/signup' do
    content_type :json
    json = JSON.parse(request.body.read)
    if user = User.signup(json['username'], json['password'])
      user.to_json
    else
      halt 500
    end
  end

  get '/version' do
    content_type :json
    { path: '/v1/meals', version: Version.string }.to_json
  end

  get '/v1/meals', auth: 'user' do
    content_type :json
    meals = Meal.find_by_user(session[:uid])
    meals
  end

  post '/v1/meals', auth: 'user' do
    content_type :json
    json = request.body.read
    meal = Meal.new(json)
    if meal.create
      meal.to_json
    else
      halt 500
    end
  end

  get '/v1/meals/:id', auth: 'user' do
    content_type :json
    meal = Meal.get(params[:id])
    if meal
      meal.to_json
    else
      halt 500
    end
  end

  put '/v1/meals/:id', auth: 'user' do
    meal = Meal.get(params[:id])
    vars = JSON.parse(request.body.read)
    meal.text = vars['text']
    meal.taken = vars['taken']
    meal.calories = vars['calories']
    if meal.update
      meal.to_json
    else
      halt 500
    end
  end

  delete '/v1/meals/:id', auth: 'user' do
    meal = Meal.get(params[:id])
    if meal.destroy
      meal
    else
      halt 500
    end
  end
end
