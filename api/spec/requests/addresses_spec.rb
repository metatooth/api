# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'Addresses', type: :request do
  let(:user) { create(:user) }
  let(:a) { create(:address, user: user) }
  let(:b) { create(:address, user: user) }
  let(:c) { create(:address, user: user) }

  before do
    user.addresses << a
    user.addresses << b
    user.addresses << c
    user.save
  end

  context 'with valid API Key' do
    let(:key) { ApiKey.create }
    let(:key_str) { key.to_s }

    context 'with valid access token' do
      let(:access_token) { create(:access_token, api_key: key, user: user) }
      let(:token) { access_token.generate_token }
      let(:token_str) { "#{user.id}:#{token}" }
      let(:headers) do
        { 'HTTP_AUTHORIZATION' =>
        "Metaspace-Token api_key=#{key_str}, access_token=#{token_str}" }
      end

      describe 'GET /users/:uid/addresses' do
        before { get "/users/#{user.id}/addresses", nil, headers }

        it 'receives HTTP status 200' do
          expect(last_response.status).to eq 200
        end

        it 'receives a json with the "data" root key' do
          expect(json_body['data']).to_not be nil
        end

        it 'receives all 3 addresses' do
          expect(json_body['data'].size).to eq 3
        end
      end

      describe 'GET /users/:uid/addresses/:id' do
        context 'with existing resource' do
          before do
            get "/users/#{user.id}/addresses/#{a.id}", nil, headers
          end

          it 'receives HTTP status 200' do
            expect(last_response.status).to eq 200
          end

          it 'receives a json with the "data" root key' do
            expect(json_body['data']).to_not be nil
          end

          it 'receives user' do
            expect(json_body['data']['name']).to eq a.name
          end
        end

        context 'with nonexistent resource' do
          it 'gets HTTP status 404' do
            get "/users/#{user.id}/addresses/23456234", nil, headers do
              expect(last_response.status).to eq 404
            end
          end
        end
      end

      describe 'PUT /users/:uid/addresses/:id' do
        before do
          put "/users/#{user.id}/addresses/#{b.id}",
              params,
              headers
        end

        context 'with valid parameters' do
          let(:params) { { data: { name: 'Bobby' } } }

          it 'gets HTTP status 200' do
            expect(last_response.status).to eq 200
          end

          it 'receives the updated resource' do
            expect(json_body['data']['name']).to eq('Bobby')
          end

          it 'updates the record in the database' do
            expect(Address.get(b.id).name).to eq('Bobby')
          end
        end

        context 'with invalid parameters' do
          let(:params) { { data: { name: '' } } }

          it 'gets HTTP status 422' do
            expect(last_response.status).to eq 422
          end

          it 'receives the error details' do
            expect(json_body['error']['invalid_params']).to eq(
              'name' => ['Name must not be blank', 'Name must not be blank']
            )
          end

          it 'does not update a record in the database' do
            expect(Address.get(b.id).name).to eq b.name
          end
        end
      end

      describe 'DELETE /users/:uid/addresses/:id' do
        context 'with existing resource' do
          before do
            delete "/users/#{user.id}/addresses/#{b.id}",
                   nil,
                   headers
          end
          it 'gets HTTP status 204' do
            expect(last_response.status).to eq 204
          end

          it 'deletes the address from the database' do
            expect(Address.count).to eq 2
          end
        end

        context 'with nonexisting resource' do
          it 'gets HTTP status 404' do
            delete "/users/#{user.id}/users/342523455", nil, headers
            expect(last_response.status).to eq 404
          end
        end
      end
    end

    context 'with invalid access token' do
      let(:headers) do
        { 'HTTP_AUTHORIZATION' =>
        "Metaspace-Token api_key=#{key}, access_token=1:fake" }
      end

      describe 'GET /users/:uid/addresses' do
        it 'returns 401' do
          get "/users/#{user.id}/addresses", nil, headers
          expect(last_response.status).to eq 401
        end
      end

      describe 'GET /addresses/:id' do
        it 'returns 401' do
          get "/users/#{user.id}/addresses/1", nil, headers
          expect(last_response.status).to eq 401
        end
      end

      describe 'DELETE /users/:uid/addresses/:id' do
        it 'returns 401' do
          delete "/users/#{user.id}/addresses/1", nil, headers
          expect(last_response.status).to eq 401
        end
      end
    end

    context 'without access token' do
      let(:headers) do
        { 'HTTP_AUTHORIZATION' => "Metaspace-Token api_key=#{key}" }
      end

      describe 'GET /users/:uid/addresses' do
        it 'returns 401' do
          get "/users/#{user.id}/addresses", nil, headers
          expect(last_response.status).to eq 401
        end
      end

      describe 'GET /users/:uid/addresses/:id' do
        it 'returns 401' do
          get "/users/#{user.id}/addresses/1", nil, headers
          expect(last_response.status).to eq 401
        end
      end

      describe 'POST /users/:uid/addresses' do
        before { post "/users/#{user.id}/addresses", params, headers }

        context 'with valid parameters' do
          let(:params) do
            { data: { email: 'someone@example.com',
                      name: 'Johnny',
                      password: 'password' } }
          end

          it 'gets HTTP status 401' do
            expect(last_response.status).to eq 401
          end
          it 'receives the newly created resource' do
          end
        end

        context 'with invalid parameters' do
          let(:params) do
            { data: { email: '', name: '', password: 'password' } }
          end

          it 'returns HTTP status 401' do
            expect(last_response.status).to eq 401
          end
        end
      end

      describe 'DELETE /users/:uid/addresses/:id' do
        it 'returns 401' do
          delete "/users/#{user.id}/addresses/1", nil, headers
          expect(last_response.status).to eq 401
        end
      end
    end
  end

  context 'with invalid API Key' do
    describe 'GET /users/:uid/addresses' do
      it 'returns HTTP status 401' do
        get "/users/#{user.id}/addresses"
        expect(last_response.status).to eq 401
      end
    end

    describe 'GET /users/:uid/addresses/:id' do
      it 'returns HTTP status 401' do
        get "/users/#{user.id}/addresses/#{a.id}"
        expect(last_response.status).to eq 401
      end
    end

    describe 'POST /users/:uid/addresses' do
      it 'returns HTTP status 401' do
        post "/users/#{user.id}/addresses"
        expect(last_response.status).to eq 401
      end
    end

    describe 'PUT /users/:uid/addresses/:id' do
      it 'returns HTTP status 401' do
        put "/users/#{user.id}/addresses/#{a.id}"
        expect(last_response.status).to eq 401
      end
    end

    describe 'DELETE /users/:uid/addresses/:id' do
      it 'returns HTTP status 401' do
        delete "/users/#{user.id}/addresses/#{a.id}"
        expect(last_response.status).to eq 401
      end
    end
  end
end
