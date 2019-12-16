# frozen_string_literal: true

# An Customer model.
class Customer
  include DataMapper::Resource

  property :id, Serial, index: true
  property :locator, Locator
  property :name, String, length: 256
  property :created_at, DateTime
  property :updated_at, DateTime
  property :deleted, ParanoidBoolean, default: false, lazy: false
  property :deleted_at, ParanoidDateTime

  belongs_to :account
  has n, :addresses
  has n, :orders

  validates_uniqueness_of :locator
  validates_presence_of :name
end
