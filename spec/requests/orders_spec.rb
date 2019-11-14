require_relative '../spec_helper'
require_relative '../../app/controllers/application_controller'
require_relative '../../app/controllers/orders_controller'

RSpec.describe 'Orders', type: :request do
  def app
    OrdersController
  end

  let(:api_key) { ApiKey.create.api_key }
  let(:headers) {{ 'HTTP_AUTHORIZATION' => "Metaspace-Token api_key=#{api_key}" }}

  describe 'GET /api/orders' do
    context 'with invalid API Key' do
      it 'gets 401 Unauthorized' do
        get '/api/orders'
        expect(last_response.status).to eq 401
      end
    end

    context 'with valid API Key' do
      context 'default behavior' do
        before { get '/api/orders', nil, headers }

        it 'gets HTTP status 200' do
          expect(last_response.status).to eq 200
        end

        it 'receives a response body' do
          expect(last_response.body).to_not be nil
        end
      end
    end
  end 
end