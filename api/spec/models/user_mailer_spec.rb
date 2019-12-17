# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../app/models/user_mailer'

RSpec.describe UserMailer, type: :mailer do
  describe '#confirmation_email' do
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

  describe '#reset_password' do
    let(:user) { create(:user, :reset_password) }
    let(:mail) { UserMailer.reset_password(user) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Reset your password')
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(['pony@unknown'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('Hello')
    end
  end

  describe '#new_product_email' do
    let(:user) { create(:user) }
    let(:product) { create(:product, account: user.account) }
    let(:mail) { UserMailer.new_product(user, product) }

    it 'renders the headers' do
      expect(mail.subject).to eq('New product created')
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(['pony@unknown'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('A new product has been created')
    end
  end
end
