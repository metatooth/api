# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'Customers', type: :request do
  let(:user) { create(:user) }
  let(:a) { create(:customer) }
  let(:b) { create(:customer) }
  let(:c) { create(:customer) }
  let(:customers) { [a, b, c] }

  before { user }
  before { customers }

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

      describe 'GET /customers' do
        before { get '/customers', nil, headers }

        it 'receives HTTP status 200' do
          expect(last_response.status).to eq 200
        end

        it 'receives a json with the "data" root key' do
          expect(json_body['data']).to_not be nil
        end

        it 'receives all 3 customers' do
          expect(json_body['data'].size).to eq 3
        end
      end

      describe 'GET /customers/:id' do
        context 'with existing resource' do
          before { get "/customers/#{a.id}", nil, headers }

          it 'receives HTTP status 200' do
            expect(last_response.status).to eq 200
          end

          it 'receives a json with the "data" root key' do
            expect(json_body['data']).to_not be nil
          end

          it 'receives customer' do
            expect(json_body['data']['name']).to eq a.name
          end
        end

        context 'with nonexistent resource' do
          it 'gets HTTP status 404' do
            get '/customers/23456234', nil, headers do
              expect(last_response.status).to eq 404
            end
          end
        end
      end

      describe 'PUT /customers/:id' do
        before { put "/customers/#{b.id}", { data: params }, headers }

        context 'with valid parameters' do
          let(:params) { { name: 'Bobby' } }

          it 'gets HTTP status 200' do
            expect(last_response.status).to eq 200
          end

          it 'receives the updated resource' do
            expect(json_body['data']['name']).to eq('Bobby')
          end

          it 'updates the record in the database' do
            expect(Customer.get(b.id).name).to eq('Bobby')
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
            expect(Customer.get(b.id).name).to eq b.name
          end
        end
      end

      describe 'DELETE /customers/:id' do
        context 'with existing resource' do
          before { delete "/customers/#{b.id}", nil, headers }
          it 'gets HTTP status 204' do
            expect(last_response.status).to eq 204
          end

          it 'deletes the customer from the database' do
            expect(Customer.count).to eq 2
          end
        end

        context 'with nonexisting resource' do
          it 'gets HTTP status 404' do
            delete '/customers/2345234', nil, headers
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

      describe 'GET /customers' do
        it 'returns 401' do
          get '/customers', nil, headers
          expect(last_response.status).to eq 401
        end
      end

      describe 'GET /customers/:id' do
        it 'returns 401' do
          get '/customers/1', nil, headers
          expect(last_response.status).to eq 401
        end
      end

      describe 'DELETE /customers/:id' do
        it 'returns 401' do
          delete '/customers/1', nil, headers
          expect(last_response.status).to eq 401
        end
      end
    end

    context 'without access token' do
      let(:headers) do
        { 'HTTP_AUTHORIZATION' => "Metaspace-Token api_key=#{key}" }
      end

      describe 'GET /customers' do
        it 'returns 401' do
          get '/customers', nil, headers
          expect(last_response.status).to eq 401
        end
      end

      describe 'GET /customers/:id' do
        it 'returns 401' do
          get '/customers/1', nil, headers
          expect(last_response.status).to eq 401
        end
      end

      describe 'POST /customers' do
        before { post '/customers', { data: params }, headers }

        context 'with valid parameters' do
          let(:params) do
            { email: 'someone@example.com',
              name: 'Johnny',
              password: 'password' }
          end

          it 'gets HTTP status 401' do
            expect(last_response.status).to eq 401
          end
          it 'receives the newly created resource' do
          end
        end

        context 'with invalid parameters' do
          let(:params) do
            { email: '', name: '', password: 'password' }
          end

          it 'returns HTTP status 401' do
            expect(last_response.status).to eq 401
          end
        end
      end

      describe 'DELETE /customers/:id' do
        it 'returns 401' do
          delete '/customers/1', nil, headers
          expect(last_response.status).to eq 401
        end
      end
    end
  end

  context 'with invalid API Key' do
    describe 'GET /customers' do
      it 'returns HTTP status 401' do
        get '/customers'
        expect(last_response.status).to eq 401
      end
    end

    describe 'GET /customers/:id' do
      it 'returns HTTP status 401' do
        get "/customers/#{a.id}"
        expect(last_response.status).to eq 401
      end
    end

    describe 'POST /customers' do
      it 'returns HTTP status 401' do
        post '/customers'
        expect(last_response.status).to eq 401
      end
    end

    describe 'PUT /customers/:id' do
      it 'returns HTTP status 401' do
        put "/customers/#{a.id}"
        expect(last_response.status).to eq 401
      end
    end

    describe 'DELETE /customers/:id' do
      it 'returns HTTP status 401' do
        delete "/customers/#{a.id}"
        expect(last_response.status).to eq 401
      end
    end
  end
end
