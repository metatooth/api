# frozen_string_literal: true

require_relative '../spec_helper'

# Specification for the Order model.
describe Order, type: :model do
  context 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:bill) }
    it { should belong_to(:ship) }
  end

  context 'validations' do
    context 'uniqueness' do
      before { create(:order) }

      it { should validate_uniqueness_of(:locator) }
    end
  end
end
