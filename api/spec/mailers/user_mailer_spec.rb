# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../app/mailers/user_mailer'

RSpec.describe UserMailer, type: :mailer do
  describe 'confirmation_email' do
    Pony.override_options = { via: :test }

    let(:user) { create(:user, account: create(:account)) }

    it 'should be saved' do
      expect(user.saved?).to eq true
    end

    let(:mail) { UserMailer.confirmation_email(user) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Confirm your Account!')
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(['pony@unknown'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('Hello')
    end
  end
end
