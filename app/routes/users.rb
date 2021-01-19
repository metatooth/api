# frozen_string_literal: true

# The users endpoints.
class App
  options '/users' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'Content-Type,Authorization'
    response['Access-Control-Allow-Methods'] = 'GET, POST'
  end

  options '/users/:id' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'Content-Type,Authorization'
    response['Access-Control-Allow-Methods'] = 'GET, PUT, DELETE'
  end

  get '/users' do
    authenticate_user

    status 200
    { data: users.to_a }.to_json
  end

  post '/users' do
    errors = UserContract.new.call(user_params).errors(full: true).to_h

    if errors.empty?
      user = user_repo.create(
        email: user_params[:email],
        name: user_params[:name],
        password: user_params[:password],
        role: user_params[:role],
        confirmation_redirect_url: user_params[:confirmation_redirect_url]
      )
      UserMailer.confirmation_email(user)
      response.headers['Location'] =
        "#{request.scheme}://#{request.host}/users/#{user[:id]}"
      status :created
      { data: user.to_h }.to_json
    else
      unprocessable_entity!(errors)
    end
  rescue StandardError => e
    puts "ERROR #{e}"
  end

  get '/users/:id' do
    authenticate_user

    if user
      status 200
      { data: user.to_h }.to_json
    else
      resource_not_found
    end
  end

  put '/users/:id' do
    authenticate_user

    if user.nil?
      resource_not_found
    else
      user_hash = user.to_h
      user_params.each do |k, v|
        user_hash[k.to_sym] = v
      end

      errors = UserContract.new.call(user_hash).errors(full: true).to_h

      if errors.empty?
        updated_user = user_repo.update(user.id, user_hash)
        status :ok
        { data: updated_user.to_h }.to_json
      else
        unprocessable_entity!(errors)
      end
    end
  end

  delete '/users/:id' do
    authenticate_user

    if user.nil?
      resource_not_found
    else
      user_repo.delete(user.id)
      status :no_content
    end
  end

  private

  def user
    @user ||= UserRepo.new(MAIN_CONTAINER).by_id(params[:id])
  rescue StandardError
    nil
  end

  def user_params
    params[:data]&.slice(:email,
                         :password,
                         :name,
                         :role,
                         :confirmation_redirect_url)
  end

  def user_repo
    @user_repo ||= UserRepo.new(MAIN_CONTAINER)
  end

  def users
    @users ||= MAIN_CONTAINER.relations[:users]
  end
end
