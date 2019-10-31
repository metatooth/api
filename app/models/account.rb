# frozen_string_literal: true

# An Account model.
class Account
  include DataMapper::Resource

  property :id, Serial, index: true
  property :locator, Locator
  property :name, String, length: 256, required: true
  property :created_at, DateTime, required: true
  property :updated_at, DateTime, required: true
  property :deleted, ParanoidBoolean
  property :deleted_at, ParanoidDateTime

  belongs_to :owner, 'User'
  belongs_to :location, 'Address'
  has n, :users
  has n, :customers

  validates_uniqueness_of :locator
  validates_presence_of :name
  validates_presence_of :owner
  validates_presence_of :location

end
