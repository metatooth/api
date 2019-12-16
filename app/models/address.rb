# frozen_string_literal: true

# An Address model.
class Address
  include DataMapper::Resource

  property :id, Serial, index: true
  property :locator, Locator
  property :name, String, required: true
  property :organization, String
  property :address1, String, required: true
  property :address2, String
  property :city, String, required: true
  property :state, String
  property :zip5, String
  property :zip4, String
  property :postcode, String
  property :created_at, DateTime
  property :updated_at, DateTime
  property :deleted, ParanoidBoolean, default: false, lazy: false
  property :deleted_at, ParanoidDateTime

  belongs_to :customer

  validates_uniqueness_of :locator
  validates_presence_of :name, :address1, :city, :state
  validates_format_of :state, with: /^[A-Z][A-Z]$/
  validates_format_of :zip5, with: /^\d{5}$/
  validates_format_of :zip4, with: /^\d{4}$/
end
