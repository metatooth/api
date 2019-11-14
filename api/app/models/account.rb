# frozen_string_literal: true

# An Account model.
class Account
  include DataMapper::Resource

  property :id, Serial, index: true
  property :locator, Locator
  property :name, String, length: 256, required: true
  property :created_at, DateTime
  property :updated_at, DateTime
  property :deleted, ParanoidBoolean
  property :deleted_at, ParanoidDateTime

  has n, :users
  has n, :customers

  validates_uniqueness_of :locator
  validates_presence_of :name

end
