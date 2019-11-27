# frozen_string_literal: true

# The users endpoints.
class UsersController < ApplicationController
  options '/users' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'Content-Type,Authorization'
    response['Access-Control-Allow-Methods'] = 'GET, POST'
  end

  get '/users' do
    users = User.all

    status 200
    { data: users }.to_json
  end

  post '/users' do
    puts "POST /users"
    json = JSON.parse(request.body.read)
    if (user = User.signup(json['email'], Time.now.to_i))
      user.to_json
    else
      halt 500
    end
  end

  options '/users/:id' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'Content-Type,Authorization'
    response['Access-Control-Allow-Methods'] = 'GET, PUT, DELETE'
  end

  get '/users/:id' do
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

  put '/users/:id' do
    if (user = User.get(params[:id]))
      vars = JSON.parse(request.body.read)

      if @user.user_manager?
        user.type = vars['type'] unless vars['type'].nil?

        user.email = vars['email'] unless vars['email'].nil?

        unless vars['failed_attempts'].nil?
          user.failed_attempts = vars['failed_attempts']
        end

        unless vars['password'].nil?
          user.init_password_salt_and_hash(vars['password'])
        end
      elsif user.id == @user.id
        unless vars['password'].nil?
          user.init_password_salt_and_hash(vars['password'])
        end
      end

      if user.update
        status 200
        user.to_json
      else
        halt 500
      end
    else
      halt 404
    end
  end

  delete '/users/:id' do
    if (user = User.get(params[:id]))
      if user.id != @user.id
        user.destroy
        true
      else
        halt 401
      end
    else
      halt 500
    end
  end
end
