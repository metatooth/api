# frozen_string_literal: true

require_relative 'locator'

# An Plan model.
class Plan
  include DataMapper::Resource
  has n, :revisions

  property :id, Serial, index: true
  property :locator, Locator
  property :name, String, length: 256
  property :created_at, DateTime
  property :updated_at, DateTime
  property :deleted, ParanoidBoolean, default: false, lazy: false
  property :deleted_at, ParanoidDateTime

  validates_uniqueness_of :locator
  validates_presence_of :name

  def destroy
    update({ deleted: true, deleted_at: DateTime.now })
  end
end
