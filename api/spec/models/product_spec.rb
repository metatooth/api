# frozen_string_literal: true

require_relative '../spec_helper'

# Specification for the Product model.
describe Product, type: :model do
  context 'associations' do
    it { should belong_to(:account) }
  end

  context 'validations' do
    context 'uniqueness' do
      before { create(:account) }

      it { should validate_uniqueness_of(:locator) }
    end
  end

end
