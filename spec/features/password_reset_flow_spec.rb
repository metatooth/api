# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'Password Reset Flow', type: :request do
  let(:john) { create(:user) }
  let(:api_key) { ApiKey.create }
  let(:headers) do
    { 'HTTP_AUTHORIZATION' =>
    "Alexandria-Token api_key=#{api_key}" }
  end
  let(:create_params) do
    { email: john.email, reset_password_redirect_url: 'http://example.com' }
  end
  let(:update_params) { { password: 'new_password' } }

  it 'resets the password' do
    expect(john.authenticate('password')).to_not be false
    # Step 1
    expect(UserMailer).to(receive(:reset_password).with(john))
    post 'password_resets', { data: create_params }, headers
    expect(last_response.status).to eq 204
    reset_token = john.reload.reset_password_token

    # Step 2
    sbj = get "/password_resets/#{reset_token}"
    expect(sbj).to redirect_to("http://example.com?reset_token=#{reset_token}")
    # Step 3
    put "/password_resets/#{reset_token}",
        { data: update_params }, headers
    expect(last_response.status).to eq 204
    expect(john.reload.authenticate('new_password')).to_not be false
  end
end
