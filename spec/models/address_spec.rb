# frozen_string_literal: true

require_relative '../spec_helper'

# Specification for the Address model.
describe Address, type: :model do
  context 'associations' do
    it { should belong_to(:account) }
  end

  context 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:address1) }
    it { should validate_presence_of(:city) }
    it { should validate_presence_of(:state) }
    it { should validate_presence_of(:zip5) }

    it { should validate_format_of(:state).with(/^[A-Z][A-Z]$/) }
    it { should validate_format_of(:zip5).with(/^\d{5}$/) }

    context 'uniqueness' do
      before { create(:address) }

      it { should validate_uniqueness_of(:locator) }
    end
  end
end
