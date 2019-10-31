# frozen_string_literal: true

# An Address model.
class Address
  include DataMapper::Resource

  property :id, Serial, index: true
  property :locator, Locator
  property :name, String
  property :firm, String
  property :address1, String
  property :address2, String
  property :city, String
  property :state, String
  property :zip5, String
  property :zip4, String
  property :created_at, DateTime, required: true
  property :updated_at, DateTime, required: true
  property :deleted, ParanoidBoolean
  property :deleted_at, ParanoidDateTime

  belongs_to :account
  
  validates_uniqueness_of :locator
  validates_presence_of :name, :address1, :city, :state, :zip5
  validates_format_of :state, with: /^[A-Z][A-Z]$/
  validates_format_of :zip5, with: /^\d{5}$/
end
