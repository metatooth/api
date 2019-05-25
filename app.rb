require 'sinatra'

require_relative 'meal'
require_relative 'version'

class App < Sinatra::Base

    get '/version' do
        content_type :json
        { path: '/v1/meals', version: Version.string }.to_json
    end

    get '/v1/meals' do
        content_type :json
        @meals = Meal.find_by_user(current_user)
        @meals
    end

    post '/v1/meals' do
        content_type :json
        json = request.body.read
        @meal = Meal.new(json)
        if @meal.create
            @meal.to_json
        else
            halt 500
        end
    end

    get '/v1/meals/:id' do
        content_type :json
        meal =  Meal.get(params[:id])
        if meal
            meal.to_json
        else
            halt 500
        end
    end

    put '/v1/meals/:id' do
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

    delete '/v1/meals/:id' do
        meal = Meal.get(params[:id])
        if meal.delete
            meal
        else
            halt 500
        end
    end

    protected

    def current_user
    end
end
