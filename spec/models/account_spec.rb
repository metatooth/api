# frozen_string_literal: true

require_relative '../spec_helper'

# Specification for the Account model.
RSpec.describe Account, type: :model do
  let(:account) { create(:account) }

  context 'associations' do
    it { should have_many(:users) }
    it { should have_many(:customers) }
  end

  context 'validations' do
    it { should validate_presence_of(:name) }

    context 'uniqueness' do
      it { should validate_uniqueness_of(:locator) }
    end
  end
end
