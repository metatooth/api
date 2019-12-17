# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'Orders', type: :request do
  let(:a) { create(:order) }
  let(:b) { create(:order) }
  let(:c) { create(:order) }
  let(:orders) { [a, b, c] }
  let(:customer) { a.customer }
  let(:user) { create(:user, account: customer.account) }

  before do
    orders
    customer
    user

    customer.orders << a
    customer.orders << b
    customer.orders << c
    customer.save
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

      describe 'GET /orders' do
        before { get '/orders', nil, headers }

        it 'receives HTTP status 200' do
          expect(last_response.status).to eq 200
        end

        it 'receives a json with the "data" root key' do
          expect(json_body['data']).to_not be nil
        end

        it 'receives all 3 orders' do
          expect(json_body['data'].size).to eq 3
        end
      end

      describe 'GET /orders/:id' do
        context 'with existing resource' do
          before { get "/orders/#{a.id}", nil, headers }

          it 'receives HTTP status 200' do
            expect(last_response.status).to eq 200
          end

          it 'receives a json with the "data" root key' do
            expect(json_body['data']).to_not be nil
          end

          it 'receives order' do
            expect(json_body['data']['locator']).to eq a.locator
          end
        end

        context 'with nonexistent resource' do
          it 'gets HTTP status 404' do
            get '/orders/23456234', nil, headers do
              expect(last_response.status).to eq 404
            end
          end
        end
      end

      describe 'PUT /orders/:id' do
        before { put "/orders/#{b.id}", { data: params }, headers }

        context 'with valid parameters' do
          let(:params) { { shipped_impression_kit_at: '1974-06-21T00:00:00-04:00' } }

          it 'gets HTTP status 200' do
            expect(last_response.status).to eq 200
          end

          it 'receives the updated resource' do
            expect(json_body['data']['shipped_impression_kit_at']).to eq('1974-06-21T00:00:00-04:00')
          end

          it 'updates the record in the database' do
            expect(Order.get(b.id).shipped_impression_kit_at).to eq(DateTime.new(1974, 6, 21, 0, 0, 0, Rational(-4, 24)))
          end
        end

        context 'with invalid parameters' do
          let(:params) { { shipped_impression_kit_at: '' } }

          it 'gets HTTP status 422' do
            expect(last_response.status).to eq 422
          end

          it 'receives the error details' do
            expect(json_body['error']['invalid_params']).to eq(
              'shipped_impression_kit_at' => ['Shipped impression kit at must be of type DateTime']
            )
          end

          it 'does not update a record in the database' do
            expect(Order.get(b.id).shipped_impression_kit_at).to eq b.shipped_impression_kit_at
          end
        end
      end

      describe 'DELETE /orders/:id' do
        context 'with existing resource' do
          before { delete "/orders/#{b.id}", nil, headers }
          it 'gets HTTP status 204' do
            expect(last_response.status).to eq 204
          end

          it 'deletes the order from the database' do
            expect(Order.count).to eq 2
          end
        end

        context 'with nonexisting resource' do
          it 'gets HTTP status 404' do
            delete '/orders/2345234', nil, headers
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

      describe 'GET /orders' do
        it 'returns 401' do
          get '/orders', nil, headers
          expect(last_response.status).to eq 401
        end
      end

      describe 'GET /orders/:id' do
        it 'returns 401' do
          get '/orders/1', nil, headers
          expect(last_response.status).to eq 401
        end
      end

      describe 'DELETE /orders/:id' do
        it 'returns 401' do
          delete '/orders/1', nil, headers
          expect(last_response.status).to eq 401
        end
      end
    end

    context 'without access token' do
      let(:headers) do
        { 'HTTP_AUTHORIZATION' => "Metaspace-Token api_key=#{key}" }
      end

      describe 'GET /orders' do
        it 'returns 401' do
          get '/orders', nil, headers
          expect(last_response.status).to eq 401
        end
      end

      describe 'GET /orders/:id' do
        it 'returns 401' do
          get '/orders/1', nil, headers
          expect(last_response.status).to eq 401
        end
      end

      describe 'POST /orders' do
        before { post '/orders', { data: params }, headers }

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

      describe 'DELETE /orders/:id' do
        it 'returns 401' do
          delete '/orders/1', nil, headers
          expect(last_response.status).to eq 401
        end
      end
    end
  end

  context 'with invalid API Key' do
    describe 'GET /orders' do
      it 'returns HTTP status 401' do
        get '/orders'
        expect(last_response.status).to eq 401
      end
    end

    describe 'GET /orders/:id' do
      it 'returns HTTP status 401' do
        get "/orders/#{a.id}"
        expect(last_response.status).to eq 401
      end
    end

    describe 'POST /orders' do
      it 'returns HTTP status 401' do
        post '/orders'
        expect(last_response.status).to eq 401
      end
    end

    describe 'PUT /orders/:id' do
      it 'returns HTTP status 401' do
        put "/orders/#{a.id}"
        expect(last_response.status).to eq 401
      end
    end

    describe 'DELETE /orders/:id' do
      it 'returns HTTP status 401' do
        delete "/orders/#{a.id}"
        expect(last_response.status).to eq 401
      end
    end
  end
end
