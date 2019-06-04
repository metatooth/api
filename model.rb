# frozen_string_literal: true

require 'json'
require 'google/cloud/firestore'

# A base class for all Firestore-backed models.
class Model
  @@firestore = Google::Cloud::Firestore.new project_id: ENV['PROJECT_ID']
end
