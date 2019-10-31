# frozen_string_literal: true

# An Customer model.
class Customer
  include DataMapper::Resource

  property :id, Serial, index: true
  property :locator, Locator
  property :name, String, length: 256, required: true
  property :created_at, DateTime, required: true
  property :updated_at, DateTime, required: true
  property :deleted, ParanoidBoolean
  property :deleted_at, ParanoidDateTime

  belongs_to :account
  belongs_to :location, 'Address'
  has n, :addresses
  has n, :orders

  validates_uniqueness_of :locator
  validates_presence_of :name

end
