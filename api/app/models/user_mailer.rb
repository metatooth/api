# frozen_string_literal: true

require_relative 'application_mailer'

# Class to handle user mail
class UserMailer < ApplicationMailer
  def self.confirmation_email(user)
    @user = user
    @user.update(confirmation_sent_at: DateTime.now)
    mail(to: @user.email,
         subject: 'Confirm your Account!',
         template: 'user_confirmation_email')
  end

  def self.reset_password(user)
    @user = user
    @user.update(reset_password_sent_at: DateTime.now)
    mail(to: @user.email,
         subject: 'Reset your password',
         template: 'user_reset_password')
  end
end