# frozen_string_literal: true

# Controller for user confirmations
class UserConfirmationsController < ApplicationController
  get '/user_confirmations/:token' do
    confirmation_token_not_found

    user.confirm

    if user.confirmation_redirect_url
      redirect(user.confirmation_redirect_url, 303)
    else
      'You are now confirmed!'
    end
  end

  private

  def confirmation_token_not_found
    halt(404, 'Token not found') unless user
  end

  def confirmation_token
    @confirmation_token ||= params[:token]
  end

  def user
    @user ||= User.first(confirmation_token: confirmation_token)
  end
end
