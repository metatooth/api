# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../app/controllers/application_controller.rb'
require_relative '../../app/controllers/users_controller.rb'

RSpec.describe 'Users', type: :request do
  def app
    UsersController
  end

  let(:api_key) { ApiKey.create }
  let(:headers) do
    { 'HTTP_AUTHORIZATION' => "Metaspace-Token api_key=#{api_key}" }
  end
  let(:a) { create(:user) }
  let(:b) { create(:user) }
  let(:c) { create(:user) }
  let(:users) { [a, b, c] }

  let(:json_body) { JSON.parse(last_response.body) }

  describe 'GET /api/users' do
    before { users }

    context 'default behavior' do
      before { get '/api/users', nil, headers }

      it 'receives HTTP status 200' do
        expect(last_response.status).to eq 200
      end

      it 'receives a json with the "data" root key' do
        expect(json_body['data']).to_not be nil
      end

      it 'receives all 3 users' do
        expect(json_body['data'].size).to eq 3
      end
    end
  end

  describe 'GET /api/users/:id' do
  end

  describe 'POST /api/users' do
  end

  describe 'PUT /api/users/:id' do
  end

  describe 'DELETE /api/users/:id' do
  end
end
