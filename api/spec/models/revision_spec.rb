# frozen_string_literal: true

require_relative '../spec_helper'

# Specification for the Revision model.
describe Revision, type: :model do
  context 'associations' do
    it { should belong_to(:plan) }
  end

  context 'validations' do
    context 'uniqueness' do
      before { create(:revision) }

      it { should validate_uniqueness_of(:locator) }
    end
  end
end
