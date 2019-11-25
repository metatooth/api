# frozen_string_literal: true

# Helper object for password reset
class PasswordReset
  attr_accessor :email, :reset_password_redirect_url, :reset_token

  def create
    return false if user.nil?
    return false unless valid?
    return false unless user.init_password_reset(reset_password_redirect_url)

    true
  end

  def errors
    errors = []
    errors.append('email must be present') if email.nil? || email.empty?
    if reset_password_redirect_url.nil? || reset_password_redirect_url.empty?
      errors.append('reset_password_redirect_url must be present')
    end
    errors
  end

  def initialize(params)
    if params
      self.email = params[:email]
      self.reset_password_redirect_url = params[:reset_password_redirect_url]
      self.reset_token = params[:reset_token]
    end
  end

  def redirect_url
    build_redirect_url
  end

  def user
    @user ||= retrieve_user
  end

  def valid?
    return false if email.nil? || email.empty?
    if reset_password_redirect_url.nil? || reset_password_redirect_url.empty?
      return false
    end

    true
  end

  private

  def retrieve_user
    user = if email
             user_with_email
           else
             user_with_token
    end

    raise Exception unless user

    user
  end

  def user_with_email
    User.first(email: email.downcase)
  end

  def user_with_token
    User.first(reset_password_token: reset_token)
  end

  def build_redirect_url
    url = user.reset_password_redirect_url
    query_params = Rack::Utils.parse_query(URI(url).query)
    if query_params.any?
      "#{url}&reset_token=#{reset_token}"
    else
      "#{url}?reset_token=#{reset_token}"
    end
  end
end
