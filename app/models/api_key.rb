# frozen_string_literal: true

module Entities
  # An API Key model.
  class ApiKey < ROM::Struct
    def api_key_string
      "#{id}:#{api_key}"
    end
  end
end
