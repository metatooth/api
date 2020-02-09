# frozen_string_literal: true

require_relative '../spec_helper'

# Specification for the Product model.
describe Product, type: :model do
  context 'validations' do
    context 'uniqueness' do
      it { should validate_uniqueness_of(:locator) }
      it { should validate_presence_of(:name) }
    end
  end
end
