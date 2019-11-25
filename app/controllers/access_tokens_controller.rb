# frozen_string_literal: true

# Endpoints to create and delete access tokens
class AccessTokensController < ApplicationController
  post '/access_tokens' do
    user = User.first(email: login_params[:email].downcase)

    if user.nil?
      status 404
    elsif user.authenticate(login_params[:password])
      previous = AccessToken.first(user: user, api_key: api_key)
      previous&.destroy

      access_token = AccessToken.create(user: user, api_key: api_key)
      token = access_token.generate_token

      status 201
      {
        data: {
          token: token,
          user: { id: user.id }
        },
        status: :created
      }.to_json
    else
      status 422
      { error: { message: 'Invalid credentials.' } }.to_json
    end
  end

  delete '/access_tokens' do
    if access_token
      access_token.destroy
      status 204
    else
      halt 401
    end
  end

  private

  def login_params
    params[:data].slice(:email, :password)
  end
end
