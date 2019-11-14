# frozen_string_literal: true

require_relative '../spec_helper'

# Specification for the Account model.
describe Account, type: :model do
  context 'associations' do
    it { should belong_to(:owner) }
    it { should belong_to(:location) }
    it { should have_many(:users) }
    it { should have_many(:customers) }
  end

  context 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:owner) }
    it { should validate_presence_of(:location) }

    context 'uniqueness' do
      before { create(:account) }

      it { should validate_uniqueness_of(:locator) }
    end
  end
end
