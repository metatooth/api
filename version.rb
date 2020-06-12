# frozen_string_literal: true

# The version.
class Version
  def self.string
    File.read('VERSION').gsub("\n", '')
  end
end
