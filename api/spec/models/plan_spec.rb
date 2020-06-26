# frozen_string_literal: true

require_relative '../spec_helper'

# Specification for the Plan model.
describe Plan, type: :model do
  context 'validations' do
    context 'uniqueness' do
      before { create(:plan) }

      it { should validate_uniqueness_of(:locator) }
    end
  end
end
