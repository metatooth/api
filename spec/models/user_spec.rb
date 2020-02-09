# frozen_string_literal: true

require_relative '../spec_helper'

# Specification for the User model.
RSpec.describe User, type: :model do
  let(:user) { create(:user) }

  it 'should be saved' do
    expect(user.saved?).to eq true
  end

  context 'validations' do
    it { should validate_presence_of(:email) }

    context 'uniqueness' do
      before { create(:user) }

      it { should validate_uniqueness_of(:locator) }
      it { should validate_uniqueness_of(:email) }
    end
  end
end
