# frozen_string_literal: true

# A model of a task
class Task
  include DataMapper::Resource

  property :id, Serial, index: true
  property :locator, UUID, unique: true 
  property :description, String, length: 1..1024, required: true
  property :completed_on, Date, required: true
  property :duration, Integer, required: true
  property :created_at, DateTime, required: true
  property :updated_at, DateTime, required: true
  property :deleted, ParanoidBoolean
  property :deleted_at, ParanoidDateTime

  belongs_to :user

end
