# frozen_string_literal: true

# An Order model.
class Order
  include DataMapper::Resource

  property :id, Serial, index: true
  property :locator, Locator
  property :created_at, DateTime
  property :updated_at, DateTime
  property :deleted, ParanoidBoolean, default: false
  property :deleted_at, ParanoidDateTime

  belongs_to :customer
  belongs_to :bill, 'Address'
  belongs_to :ship, 'Address'

  validates_uniqueness_of :locator
end
