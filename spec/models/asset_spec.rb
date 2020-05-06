# frozen_string_literal: true

require_relative '../spec_helper'

# Specification for the Asset model.
describe Asset, type: :model do
  context 'validations' do
    context 'uniqueness' do
      before { create(:asset) }

      it { should validate_uniqueness_of(:locator) }
      it { should validate_uniqueness_of(:url) }
    end
  end
end
