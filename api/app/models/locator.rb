# frozen_string_literal: true

module DataMapper
  class Property
    class Locator < String
      length 4
      unique true
      default proc { Locator.generate }

      #
      # Generates a new locator.
      #
      # @return [String]
      #  The new Locator.
      #
      def self.generate
        SecureRandom.hex(4)
      end
    end
  end
end
