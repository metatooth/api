# frozen_string_literal: true

require_relative '../spec_helper'

# Specification for the ApiKey model.
describe ApiKey, type: :model do
  let(:api_key) { ApiKey.create }

  context 'validations' do
    it { should validate_presence_of(:api_key) }
    it { should validate_presence_of(:active) }
    it { should validate_presence_of(:created_at) }
    it { should validate_presence_of(:updated_at) }
  end

  it 'is valid on creation' do
    expect(api_key).to be_valid
  end

  describe '#disable' do
    it 'disables the key' do
      api_key.disable
      expect(api_key.reload.active).to eq false
    end
  end

end
