# frozen_string_literal: true

# An Account model.
class Account
  include DataMapper::Resource
  has n, :users
  has n, :customers

  property :id, Serial
  property :locator, Locator
  property :created_at, DateTime
  property :updated_at, DateTime
  property :deleted, ParanoidBoolean, default: false, lazy: false
  property :deleted_at, ParanoidDateTime

  validates_uniqueness_of :locator
end
