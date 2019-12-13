# frozen_string_literal: true

# Helper object for password reset
class PasswordReset
  attr_accessor :email, :reset_password_redirect_url, :password,
                :reset_token, :updating

  def create
    (!user.nil? &&
       valid? &&
       user.init_password_reset(reset_password_redirect_url))
  end

  def errors
    errors = []
    if updating
      errors.append('password must be present') if password.nil? || password.empty?
    else
      errors.append('email must be present') if email.nil? || email.empty?
      if reset_password_redirect_url.nil? || reset_password_redirect_url.empty?
        errors.append('reset_password_redirect_url must be present')
      end
    end

    errors
  end

  def initialize(params)
    return unless params

    self.email = params[:email]
    self.reset_password_redirect_url = params[:reset_password_redirect_url]
    self.reset_token = params[:reset_token]
    self.password = params[:password]
  end

  def redirect_url
    build_redirect_url
  end

  def update
    self.updating = true
    (!user.nil? && valid? && user.complete_password_reset(password))
  end

  def user
    @user ||= retrieve_user
  end

  def valid?
    if updating
      return false if password.nil? || password.empty?
    else
      return false if email.nil? || email.empty?
      return false if reset_password_redirect_url.nil? || reset_password_redirect_url.empty?
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
