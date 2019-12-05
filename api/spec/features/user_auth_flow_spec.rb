# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../app/controllers/users_controller'

RSpec.describe 'User Auth Flow', type: :request do
  Pony.override_options = { via: :test }

  def app
    UsersController
  end

  def headers(user_id = nil, token = nil)
    api_key_str = "#{api_key.id}:#{api_key.api_key}"
    if user_id && token
      token_str = "#{user_id}:#{token}"
      { 'HTTP_AUTHORIZATION' =>
      "Metaspace-Token api_key=#{api_key_str}, access_token=#{token_str}" }
    else
      { 'HTTP_AUTHORIZATION' =>
        "Metaspace-Token api_key=#{api_key_str}" }
    end
  end

  let(:api_key) { ApiKey.create }
  let(:email) { 'john@gmail.com' }
  let(:password) { 'password' }
  let(:params) { { data: { email: email, password: password, name: 'Johnny' } } }

  it 'authenticate a new user' do
    post '/users', params, headers
    expect(last_response.status).to eq 201
    id = json_body['data']['id']
  end
end
