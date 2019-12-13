# frozen_string_literal: true

require_relative '../models/user_mailer'

# The users endpoints.
class App
  options '/users' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'Content-Type,Authorization'
    response['Access-Control-Allow-Methods'] = 'GET, POST'
  end

  get '/users' do
    authenticate_user

    users = User.all

    status 200
    { data: users }.to_json
  end

  post '/users' do
    user.account = Account.create

    if user.save
      UserMailer.confirmation_email(user)
      response.headers['Location'] = "#{request.scheme}://#{request.host}/users/#{user.id}"
      status :created
      { data: user }.to_json
    else
      unprocessable_entity!(user)
    end
  end

  options '/users/:id' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'Content-Type,Authorization'
    response['Access-Control-Allow-Methods'] = 'GET, PUT, DELETE'
  end

  get '/users/:id' do
    authenticate_user

    if user
      status 200
      { data: user }.to_json
    else
      resource_not_found
    end
  end

  put '/users/:id' do
    authenticate_user

    if user.nil?
      resource_not_found
    else
      if user.update(user_params)
        status :ok
        { data: user }.to_json
      else
        unprocessable_entity!(user)
      end
    end
  end

  delete '/users/:id' do
    authenticate_user

    if user.nil?
      resource_not_found
    else
      user.destroy
      status :no_content
    end
  end

  private

  def user
    @user ||= params[:id] ? User.get(params[:id]) : User.new(user_params)
  end

  def user_params
    params[:data]&.slice(:email, :password, :name, :role, :confirmation_redirect_url)
  end
end
