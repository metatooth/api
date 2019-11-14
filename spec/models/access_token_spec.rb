require_relative '../spec_helper'

RSpec.describe AccessToken, type: :model do
  let(:access_token) { create(:access_token) }

  it 'has a valid factory' do
    expect(build(:access_token).valid?).to eq true
  end

  #it { should validate_presence_of(:user) }
  #it { should validate_presence_of(:api_key) }

  describe '#authenticate' do
    context 'when valid' do
      it 'authenticates' do
        token = access_token.generate_token
        expect(access_token.authenticate(token)).to eq true
      end
    end
    context 'when invalid' do
      it 'fails to authenticate' do
        access_token.generate_token
        expect(access_token.authenticate('fake')).to eq false
      end
    end
  end

  describe '#expired?' do
    context 'when expired' do
      it 'returns true' do
        access_token.update(created_at: DateTime.now - 15)
        expect(access_token.expired?).to eq true
      end
    end

    context 'when not expired' do
      it 'returns false' do
        access_token.update(created_at: DateTime.now - 10)
        expect(access_token.expired?).to eq false
      end
    end
  end

  describe '#generate_token' do
    it 'generates an access token digest' do
      access_token.generate_token
      expect(access_token.token_digest).to_not eq nil
    end

    it 'returns an access token' do
      token = access_token.generate_token
      expect(token).to_not eq nil
    end
  end
  
end