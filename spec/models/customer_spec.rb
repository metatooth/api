# frozen_string_literal: true

require_relative '../spec_helper'

# Specification for the Customer model.
describe Customer, type: :model do
  context 'associations' do
    it { should belong_to(:account) }
    it { should have_many(:addresses) }
    it { should have_many(:orders) }
  end

  context 'validations' do
    it { should validate_presence_of(:name) }

    context 'uniqueness' do
      before { create(:user) }

      it { should validate_uniqueness_of(:locator) }
    end
  end
end
