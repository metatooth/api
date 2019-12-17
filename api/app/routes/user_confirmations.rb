# frozen_string_literal: true

# Controller for user confirmations
class App
  get '/user_confirmations/:token' do
    confirmation_token_not_found

    confirmed_user.confirm

    if confirmed_user.confirmation_redirect_url
      redirect(confirmed_user.confirmation_redirect_url, 303)
    else
      'You are now confirmed!'
    end
  end

  private

  def confirmation_token_not_found
    halt(404, 'Token not found') unless confirmed_user
  end

  def confirmation_token
    @confirmation_token ||= params[:token]
  end

  def confirmed_user
    @confirmed_user ||= User.first(confirmation_token: confirmation_token)
  end
end
