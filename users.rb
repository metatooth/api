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

  post '/v1/users', auth: 'user_manager' do
    json = JSON.parse(request.body.read)
    if (user = User.signup(json['email'], Time.now.to_i))
      user.to_json
    else
      halt 500
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
      vars = JSON.parse(request.body.read)

      if @user.user_manager?
        user.type = vars['type'] unless vars['type'].nil?

        user.email = vars['email'] unless vars['email'].nil?

        unless vars['preferred_working_seconds_per_day'].nil?
          user.preferred_working_seconds_per_day = vars['preferred_working_seconds_per_day'].to_f
        end

        unless vars['failed_attempts'].nil?
          user.failed_attempts = vars['failed_attempts']
        end

        unless vars['password'].nil?
          user.init_password_salt_and_hash(vars['password'])
        end
      elsif user.id == @user.id
        unless vars['preferred_working_seconds_per_day'].nil?
          user.preferred_working_seconds_per_day = vars['preferred_working_seconds_per_day'].to_f
        end

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

  delete '/v1/users/:id', auth: 'user_manager' do
    if (user = User.get(params[:id]))
      puts "DOOMED #{user.id}..."
      if user.id != @user.id
        puts 'Destroy...'
        user.destroy
        puts 'Done!'
        true
      else
        halt 401
      end
    else
      halt 500
    end
  end
end
