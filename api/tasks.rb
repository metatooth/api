# frozen_string_literal: true

require 'haml'

require_relative 'task'

# The tasks endpoints.
class App < Sinatra::Base
  options '/v1/tasks' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'Content-Type,Authorization'
    response['Access-Control-Allow-Methods'] = 'GET, POST'
  end

  get '/v1/tasks', auth: 'user' do
    tasks = if @user.type == 'Admin'
              Task.all
            else
              Task.find_by_user(@user.id)
            end

    from = Time.parse(params[:from]) if params[:from]
    to = Time.parse(params[:to]) if params[:to]

    # :NOTE: 20190605 Terry: Inclusive of the 'to' date.

    to += 24 * 60 * 60 if to

    now = Time.now
    from ||= now - 30 * 24 * 60 * 60
    to ||= now

    @tasks = tasks.select { |v| v.completed_on > from && v.completed_on < to }

    status 200
    if 'html' == params[:format]
      haml :tasks
    else
      @tasks.to_json
    end
  end

  post '/v1/tasks', auth: 'user' do
    task = Task.new(request.body.read)
    task.user_id = @user.id

    if task.create
      status 200
      task.to_json
    else
      halt 500
    end
  end

  options '/v1/tasks/:id' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'Content-Type,Authorization'
    response['Access-Control-Allow-Methods'] = 'GET, PUT, DELETE'
  end

  get '/v1/tasks/:id', auth: 'user' do
    if (task = Task.get(params[:id]))
      if @user.type == 'Admin' || @user.id == task.user_id
        status 200
        task.to_json
      else
        halt 401
      end
    else
      halt 500
    end
  end

  put '/v1/tasks/:id', auth: 'user' do
    if (task = Task.get(params[:id]))
      if @user.type == 'Admin' || @user.id == task.user_id
        vars = JSON.parse(request.body.read)
        task.description = vars['description']
        task.completed_on = Time.parse(vars['completed_on'])
        task.duration = vars['duration']
        if task.update
          status 200
          task.to_json
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

  delete '/v1/tasks/:id', auth: 'user' do
    if (task = Task.get(params[:id]))
      if (@user.type == 'Admin' || @user.id == task.user_id)
        status 204 if task.destroy
      else
        halt 401
      end
    else
      halt 500
    end
  end
end

require_relative 'notes'
