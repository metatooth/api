# frozen_string_literal: true

require 'json'
require 'google/cloud/firestore'

class Model
  @@firestore = Google::Cloud::Firestore.new project_id: ENV['PROJECT_ID']
end
