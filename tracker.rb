# frozen_string_literal: true


# A model of a time tracker
class Tracker
  include DataMapper::Resource

  property :id, Serial, index: true

  belongs_to :user

end
