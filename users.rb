# frozen_string_literal: true

# The users endpoints.
class App < Sinatra::Base
  options '/v1/users' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'Content-Type,Authorization'
    response['Access-Control-Allow-Methods'] = 'GET, POST'
  end

  get '/v1/users', auth: 'user' do
    curr = @user

    users = if curr.user_manager?
              User.all
            else
              [curr]
            end

    users.to_json
  end

  post '/v1/users', auth: 'user' do
    content_type :json
    # :TODO: 20190605 Terry: DRY it up with /v1/signup"
    curr = @user
    if !curr.nil? && curr.is_user_manager?
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

        unless vars['password'].nil?
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
      # :NOTE: 20190605 Terry: Authenticated user cannot delete themselves.
      # Must be User Manager role.
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
