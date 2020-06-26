# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'Revisions', type: :request do
  let(:plan) { create(:plan) }
  let(:a) { create(:revision, plan: plan) }
  let(:b) { create(:revision, plan: plan) }
  let(:c) { create(:revision, plan: plan) }
  let(:revisions) { [a, b, c] }
  let(:x) { create(:asset, revision: a) }
  let(:y) { create(:asset, revision: b) }
  let(:z) { create(:asset, revision: c) }
  let(:assets) { [x, y, z] }

  before do
    plan
    revisions
    assets
  end

  context 'with valid API Key' do
    let(:key) { ApiKey.create }
    let(:key_str) { key.to_s }

    let(:headers) do
      { 'HTTP_AUTHORIZATION' => "Metaspace-Token api_key=#{key_str}" }
    end

    describe 'GET /plans/:pid/revisions' do
      before { get "/plans/#{plan.locator}/revisions", nil, headers }

      it 'receives HTTP status 200' do
        expect(last_response.status).to eq 200
      end

      it 'receives a json with the "data" root key' do
        expect(json_body['data']).to_not be nil
      end

      it 'receives all 3 revisions' do
        expect(json_body['data'].size).to eq 3
      end
    end

    describe 'GET /plans/:pid/revisions/:id' do
      context 'with existing resource' do
        before { get "/plans/#{plan.locator}/revisions/#{a.locator}", nil, headers }

        it 'receives HTTP status 200' do
          expect(last_response.status).to eq 200
        end

        it 'receives a json with the "data" root key' do
          expect(json_body['data']).to_not be nil
        end

        it 'receives revision' do
          expect(json_body['data']['locator']).to eq a.locator
        end
      end

      context 'with nonexistent resource' do
        it 'gets HTTP status 404' do
          get "/plans/#{plan.locator}/revisions/23456234", nil, headers do
            expect(last_response.status).to eq 404
          end
        end
      end
    end

    describe 'PUT /plans/:pid/revisions/:id' do
      before { put "/plans/#{plan.locator}/revisions/#{b.locator}", { data: params }, headers }

      context 'with valid parameters' do
        let(:params) do
          { description: 'Metatooth RSpec' }
        end

        it 'gets HTTP status 200' do
          expect(last_response.status).to eq 200
        end

        it 'receives the updated resource' do
          expect(json_body['data']['description']).to eq(
            'Metatooth RSpec'
          )
        end

        it 'updates the record in the database' do
          expect(Revision.get(b.id).description).to eq(
            'Metatooth RSpec'
          )
        end
      end

      context 'with invalid parameters' do
        let(:params) { { number: '' } }

        it 'gets HTTP status 422' do
          expect(last_response.status).to eq 422
        end

        it 'receives the error details' do
          expect(json_body['error']['invalid_params']).to eq(
            'number' =>
            ['Number must be an integer', 'Number must not be blank']
          )
        end

        it 'does not update a record in the database' do
          expect(Revision.get(b.id).number).to eq(
            b.number
          )
        end
      end
    end

    describe 'DELETE /plans/:pid/revisions/:id' do
      context 'with existing resource' do
        before { delete "/plans/#{plan.locator}/revisions/#{b.locator}", nil, headers }
        it 'gets HTTP status 204' do
          expect(last_response.status).to eq 204
        end

        it 'deletes the revision from the database' do
          expect(Revision.count).to eq 2
        end
      end

      context 'with nonexisting resource' do
        it 'gets HTTP status 404' do
          delete "/plans/#{plan.locator}/revisions/2345234", nil, headers
          expect(last_response.status).to eq 404
        end
      end
    end
  end

  context 'with invalid API Key' do
    describe '/plans/:pid/revisions' do
      it 'returns HTTP status 401' do
        get "/plans/#{plan.locator}/revisions"
        expect(last_response.status).to eq 401
      end
    end

    describe 'GET /plans/:pid/revisions/:id' do
      it 'returns HTTP status 401' do
        get "/plans/#{plan.locator}/revisions/#{a.locator}"
        expect(last_response.status).to eq 401
      end
    end

    describe 'POST /plans/:pid/revisions' do
      it 'returns HTTP status 401' do
        post "/plans/#{plan.locator}/revisions"
        expect(last_response.status).to eq 401
      end
    end

    describe 'PUT /plans/:pid/revisions/:id' do
      it 'returns HTTP status 401' do
        put "/plans/#{plan.locator}/revisions/#{a.locator}"
        expect(last_response.status).to eq 401
      end
    end

    describe 'DELETE /plans/:pid/revisions/:id' do
      it 'returns HTTP status 401' do
        delete "/plans/#{plan.locator}/revisions/#{a.locator}"
        expect(last_response.status).to eq 401
      end
    end
  end
end
