require 'sinatra'

require_relative 'meal'
require_relative 'version'

class App < Sinatra::Base

    get '/version' do
        content_type :json
        { path: '/v1/', version: Version.string }.to_json
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
        puts "ID is #{params[:id]}"
        meal = Meal.get(params[:id])
        meal.text = params[:text]
        meal.taken = params[:taken]
        meal.calories = params[:calories]
        meal.user_id = params[:user_id]
        if meal.update
        else
        end
    end

    delete '/v1/meals/:id' do
        meal = Meal.get(params[:id])
        if meal.delete
        else
        end
    end

    protected

    def current_user
    end
end
