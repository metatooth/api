# frozen_string_literal: true

require_relative 'note'

# The tasks endpoints.
class App < Sinatra::Base
  options '/v1/tasks/:id/notes' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'Content-Type,Authorization'
    response['Access-Control-Allow-Methods'] = 'GET, POST'
  end

  options '/v1/tasks/:task_id/notes/:note_id' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'Content-Type,Authorization'
    response['Access-Control-Allow-Methods'] = 'GET, PUT, DELETE'
  end

  get '/v1/tasks/:id/notes', auth: 'user' do
    if (task = Task.get(params[:id]))
      if @user.type == 'Admin' || @user.id == task.user_id
        notes = Note.find_by_task(task.id)
      else
        halt 401
      end
    else
      halt 500
    end
    notes.to_json
  end

  post '/v1/tasks/:id/notes', auth: 'user' do
    if (task = Task.get(params[:id]))
      if @user.type == 'Admin' || @user.id == task.user_id
        note = Note.new(request.body.read)
        note.task_id = task.id
        if note.create
          note.to_json
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

  get '/v1/tasks/:task_id/notes/:id', auth: 'user' do
    if (task = Task.get(params[:task_id]))
      if @user.type == 'Admin' || @user.id == task.user_id
        note = nil
        task.notes.each do |n|
          note = n if n.id == params[:id]
        end
        note.to_json
      else
        halt 401
      end
    else
      halt 500
    end
  end

  put '/v1/tasks/:task_id/notes/:id', auth: 'user' do
    if (task = Task.get(params[:task_id]))
      if @user.type == 'Admin' || @user.id == task.user_id
        vars = JSON.parse(request.body.read)

        note = nil

        task.notes.each do |n|
          note = n if n.id == params[:id]
        end

        note.text = vars['text']
        if note.update
          note.to_json
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

  delete '/v1/tasks/:task_id/notes/:id', auth: 'user' do
    if (task = Task.get(params[:task_id]))
      if @user.type == 'Admin' || @user.id == task.user_id
        note = nil

        task.notes.each do |n|
          note = n if n.id == params[:id]
        end

        note.destroy
        status 204
      else
        halt 401
      end
    else
      halt 500
    end
  end
end
