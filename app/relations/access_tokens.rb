# frozen_string_literal: true

require 'bcrypt'

# Access Token allows User access to API
class AccessTokens < ROM::Relation[:sql]
  schema(:access_tokens, infer: true) do
    associations do
      belongs_to :user
      belongs_to :api_key
    end
  end
end
