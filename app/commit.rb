# frozen_string_literal: true

# The commit.
class Commit
  def self.string
    File.read('COMMIT').gsub("\n", '')
  end
end
