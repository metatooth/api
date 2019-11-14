# frozen_string_literal: true

require_relative '../spec_helper'

# Specification for the User model.
RSpec.describe User, type: :model do
  let(:user) { build(:user) }

  context 'associations' do
    it { should belong_to(:account) }
  end

  context 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }

    context 'uniqueness' do
      before { create(:user) }

      it { should validate_uniqueness_of(:locator) }
      it { should validate_uniqueness_of(:email) }
    end
  end

  it 'has a valid factory' do
    expect(build(:user).valid?).to eq true
  end
  
end
