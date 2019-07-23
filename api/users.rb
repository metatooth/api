# frozen_string_literal: true

# The users endpoints.
class App < Sinatra::Base
  options '/v1/users' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'Content-Type,Authorization'
    response['Access-Control-Allow-Methods'] = 'GET'
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

  put '/v1/users/:id', auth: 'user_manager' do
    if (user = User.get(params[:id]))
      curr = @user
      vars = JSON.parse(request.body.read)
      
      unless vars['type'].nil?
        user.type = vars['type']
      end

      unless vars['username'].nil?
        user.username = vars['username']
      end

      unless vars['preferred_working_seconds_per_day'].nil?
        user.preferred_working_seconds_per_day = vars['preferred_working_seconds_per_day']
      end

      unless vars['failed_attempts'].nil?
        user.failed_attempts = vars['failed_attempts']
      end

      unless vars['password'].nil?
        user.init_password_salt_and_hash(vars['password'])
      end

      if user.update
        user.to_json
      else
        halt 500
      end
    else
      halt 500
    end
  end

  delete '/v1/users/:id', auth: 'user_manager' do
    if (user = User.get(params[:id]))
      puts "DOOMED #{user.id}..."
      if user.id != @user.id
        puts "Destroy..."
        user.destroy
        puts "Done!"
        true
      else
        halt 401
      end
    else
      halt 500
    end
  end
end
