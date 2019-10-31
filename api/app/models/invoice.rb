# frozen_string_literal: true

# An Invoice model.
class Invoice
  include DataMapper::Resource

  property :id, Serial, index: true
  property :locator, Locator
  property :created_at, DateTime, required: true
  property :updated_at, DateTime, required: true
  property :deleted, ParanoidBoolean
  property :deleted_at, ParanoidDateTime

  validates_uniqueness_of :locator

  belongs_to :order
end
