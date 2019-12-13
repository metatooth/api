# frozen_string_literal: true

# An Account model.
class Account
  include DataMapper::Resource

  property :id, Serial, index: true
  property :locator, Locator
  property :created_at, DateTime
  property :updated_at, DateTime
  property :deleted, ParanoidBoolean
  property :deleted_at, ParanoidDateTime

  validates_uniqueness_of :locator

  has n, :users
  has n, :customers
end
