class ApiKeys < ROM::Relation[:sql]
  schema(:api_keys, infer: true) do
    associations do
      has_many :access_tokens
    end
  end
end
