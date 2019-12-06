# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'Users', type: :request do
  let(:a) { create(:user) }
  let(:b) { create(:user) }
  let(:c) { create(:user) }
  let(:users) { [a, b, c] }

  before { users }

  context 'with valid API Key' do
    let(:key) { ApiKey.create }
    let(:key_str) { key.to_s }

    context 'with valid access token' do
      let(:access_token) { create(:access_token, api_key: key, user: a) }
      let(:token) { access_token.generate_token }
      let(:token_str) { "#{a.id}:#{token}" }
      let(:headers) do
        { 'HTTP_AUTHORIZATION' =>
        "Metaspace-Token api_key=#{key_str}, access_token=#{token_str}" }
      end

      describe 'GET /users' do
        before { get '/users', nil, headers }

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

      describe 'GET /users/:id' do
        context 'with existing resource' do
          before { get "/users/#{b.id}", nil, headers }

          it 'receives HTTP status 200' do
            expect(last_response.status).to eq 200
          end

          it 'receives a json with the "data" root key' do
            expect(json_body['data']).to_not be nil
          end

          it 'receives user' do
            expect(json_body['data']['email']).to eq b.email
          end
        end

        context 'with nonexistent resource' do
          it 'gets HTTP status 404' do
            get '/users/23456234', nil, headers do
              expect(last_response.status).to eq 404
            end
          end
        end
      end
    end

    context 'with invalid access token' do
      let(:headers) do
        { 'HTTP_AUTHORIZATION' =>
        "Metaspace-Token api_key=#{key}, access_token=1:fake" }
      end

      describe 'GET /users' do
        it 'returns 401' do
          get '/users', nil, headers
          expect(last_response.status).to eq 401
        end
      end
    end
  end

  context 'with invalid API key' do
    describe 'GET /users' do
      it 'returns HTTP status 401' do
        get '/orders'
        expect(last_response.status).to eq 401
      end
    end
  end
end
