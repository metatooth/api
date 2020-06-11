# frozen_string_literal: true

# The version.
class Version
  def self.string
    version = File.read('VERSION').gsub("\n", '')

    "#{version} (" + ENV["BUILDID"] + ")"
  end
end
