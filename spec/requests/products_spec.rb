# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'Products', type: :request do
  let(:a) { create(:product) }
  let(:b) { create(:product, account: a.account) }
  let(:c) { create(:product, account: a.account) }
  let(:products) { [a, b, c] }
  let(:user) { create(:user, account: a.account) }

  before do
    products
    user
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

      describe 'POST /products' do
        before { post '/products', { data: params }, headers }

        context 'with valid parameters' do
          let(:params) do
            { name: 'nightguard',
              description: 'custom night guard' }
          end

          it 'gets HTTPS status 201' do
            expect(last_response.status).to eq 201
          end
        end

        context 'with invalid parameters' do
          let(:params) { { name: '' } }
        end
      end

      describe 'PUT /products/:id' do
        before { put "/products/#{b.id}", { data: params }, headers }

        context 'with valid parameters' do
          let(:params) { { name: 'Bobby' } }

          it 'gets HTTP status 200' do
            expect(last_response.status).to eq 200
          end

          it 'receives the updated resource' do
            expect(json_body['data']['name']).to eq('Bobby')
          end

          it 'updates the record in the database' do
            expect(Product.get(b.id).name).to eq('Bobby')
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
            expect(Product.get(b.id).name).to eq b.name
          end
        end
      end

      describe 'DELETE /products/:id' do
        context 'with existing resource' do
          before { delete "/products/#{b.id}", nil, headers }
          it 'gets HTTP status 204' do
            expect(last_response.status).to eq 204
          end

          it 'deletes the product from the database' do
            expect(Product.count).to eq 2
          end
        end

        context 'with nonexisting resource' do
          it 'gets HTTP status 404' do
            delete '/products/342523455', nil, headers
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

      describe 'POST /products' do
        it 'returns HTTP status 401' do
          post '/orders', nil, headers
          expect(last_response.status).to eq 401
        end
      end

      describe 'PUT /products/:id' do
        it 'returns HTTP status 401' do
          put "/orders/#{a.id}", nil, headers
          expect(last_response.status).to eq 401
        end
      end

      describe 'DELETE /products/:id' do
        it 'returns 401' do
          delete '/products/1', nil, headers
          expect(last_response.status).to eq 401
        end
      end
    end

    context 'without access token' do
      let(:headers) do
        { 'HTTP_AUTHORIZATION' => "Metaspace-Token api_key=#{key}" }
      end

      describe 'GET /products' do
        before { get '/products', nil, headers }

        it 'receives HTTP status 200' do
          expect(last_response.status).to eq 200
        end

        it 'receives a json with the "data" root key' do
          expect(json_body['data']).to_not be nil
        end

        it 'receives all 3 products' do
          expect(json_body['data'].size).to eq 3
        end
      end

      describe 'GET /products/:id' do
        context 'with existing resource' do
          before { get "/products/#{b.id}", nil, headers }

          it 'receives HTTP status 200' do
            expect(last_response.status).to eq 200
          end

          it 'receives a json with the "data" root key' do
            expect(json_body['data']).to_not be nil
          end

          it 'receives product' do
            expect(json_body['data']['name']).to eq b.name
          end
        end

        context 'with nonexistent resource' do
          it 'gets HTTP status 404' do
            get '/products/23456234', nil, headers do
              expect(last_response.status).to eq 404
            end
          end
        end
      end
    end
  end

  context 'with invalid API Key' do
    describe 'GET /products' do
      it 'returns HTTP status 401' do
        get '/orders'
        expect(last_response.status).to eq 401
      end
    end

    describe 'GET /products/:id' do
      it 'returns HTTP status 401' do
        get "/orders/#{a.id}"
        expect(last_response.status).to eq 401
      end
    end

    describe 'POST /products' do
      it 'returns HTTP status 401' do
        post '/orders'
        expect(last_response.status).to eq 401
      end
    end

    describe 'PUT /products/:id' do
      it 'returns HTTP status 401' do
        put "/orders/#{a.id}"
        expect(last_response.status).to eq 401
      end
    end

    describe 'DELETE /products/:id' do
      it 'returns HTTP status 401' do
        delete "/orders/#{a.id}"
        expect(last_response.status).to eq 401
      end
    end
  end
end
