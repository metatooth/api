# frozen_string_literal: true

# The version.
class Version
  def self.string
    "DEV.#{File.read('BUILDID').gsub("\n", '')}"
  end
end
