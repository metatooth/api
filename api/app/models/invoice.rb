# frozen_string_literal: true

# An Invoice model.
class Invoice
  include DataMapper::Resource

  property :id, Serial, index: true
  property :locator, Locator
  property :created_at, DateTime
  property :updated_at, DateTime
  property :deleted, ParanoidBoolean, default: false, lazy: true
  property :deleted_at, ParanoidDateTime

  validates_uniqueness_of :locator

  belongs_to :order
end
