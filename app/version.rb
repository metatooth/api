# frozen_string_literal: true

# The version.
class Version
  def self.string
    "DEV.#{File.read('BUILDID').gsub("\n", '')[1..]}"
  end
end
