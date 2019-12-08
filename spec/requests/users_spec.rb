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

      describe 'PUT /users/:id' do
        before { put "/users/#{b.id}", { data: params }, headers }

        context 'with valid parameters' do
          let(:params) { { name: 'Bobby' } }

          it 'gets HTTP status 200' do
            expect(last_response.status).to eq 200
          end

          it 'receives the updated resource' do
            expect(json_body['data']['name']).to eq('Bobby')
          end

          it 'updates the record in the database' do
            expect(User.get(b.id).name).to eq('Bobby')
          end
        end

        context 'with invalid parameters' do
          let(:params) { { name: '' } }

          it 'gets HTTP status 422' do
            expect(last_response.status).to eq 422
          end

          it 'receives the error details' do
            expect(json_body['error']['invalid_params']).to eq(
              'name' => ['Name must not be blank']
            )
          end

          it 'does not update a record in the database' do
            expect(User.get(b.id).name).to eq b.name
          end
        end
      end

      describe 'DELETE /users/:id' do
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

      describe 'GET /users/:id' do
        it 'returns 401' do
          get '/users/1', nil, headers
          expect(last_response.status).to eq 401
        end
      end

      describe 'DELETE /users/:id' do
        it 'returns 401' do
          delete '/users/1', nil, headers
          expect(last_response.status).to eq 401
        end
      end
    end

    context 'without access token' do
      let(:headers) do
        { 'HTTP_AUTHORIZATION' => "Metaspace-Token api_key=#{key}" }
      end

      describe 'GET /users' do
        it 'returns 401' do
          get '/users', nil, headers
          expect(last_response.status).to eq 401
        end
      end

      describe 'GET /users/:id' do
        it 'returns 401' do
          get '/users/1', nil, headers
          expect(last_response.status).to eq 401
        end
      end

      describe 'POST /users' do
        before { post '/users', { data: params }, headers }

        context 'with valid parameters' do
          let(:params) do
            { email: 'someone@example.com',
              name: 'Johnny',
              password: 'password' }
          end

          it 'gets HTTP status 201' do
            expect(last_response.status).to eq 201
          end

          it 'receives the newly created resource' do
            expect(json_body['data']['email']).to eq 'someone@example.com'
          end

          it 'adds a record in the database' do
            expect(User.count).to eq 4
          end

          it 'gets the new resource location in the Location header' do
            expect(last_response.headers['Location']).to eq(
              "http://example.org/users/#{User.last.id}"
            )
          end
        end

        context 'with invalid parameters' do
          let(:params) do
            { email: '', name: '', password: 'password' }
          end

          it 'returns HTTP status 422' do
            expect(last_response.status).to eq 422
          end

          it 'receives the error details' do
            expect(json_body['error']['invalid_params']).to eq(
              'email' => ['Email must not be blank'],
              'name' => ['Name must not be blank']
            )
          end
        end
      end

      describe 'DELETE /users/:id' do
        it 'returns 401' do
          delete '/users/1', nil, headers
          expect(last_response.status).to eq 401
        end
      end
    end
  end

  context 'with invalid API Key' do
    describe 'GET /users' do
      it 'returns HTTP status 401' do
        get '/orders'
        expect(last_response.status).to eq 401
      end
    end

    describe 'GET /users/:id' do
      it 'returns HTTP status 401' do
        get "/orders/#{a.id}"
        expect(last_response.status).to eq 401
      end
    end

    describe 'POST /users' do
      it 'returns HTTP status 401' do
        post '/orders'
        expect(last_response.status).to eq 401
      end
    end

    describe 'PUT /users/:id' do
      it 'returns HTTP status 401' do
        put "/orders/#{a.id}"
        expect(last_response.status).to eq 401
      end
    end

    describe 'DELETE /users/:id' do
      it 'returns HTTP status 401' do
        delete "/orders/#{a.id}"
        expect(last_response.status).to eq 401
      end
    end
  end
end
