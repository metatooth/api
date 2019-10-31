# frozen_string_literal: true

require_relative '../spec_helper'

# Specification for the Invoice model.
describe Invoice, type: :model do
  context 'associations' do
    it { should belong_to(:order) }
  end

  context 'validations' do
    context 'uniqueness' do
      before { create(:invoice) }

      it { should validate_uniqueness_of(:locator) }
    end
  end

end
