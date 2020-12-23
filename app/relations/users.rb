class Users < ROM::Relation[:sql]
  schema(:users, infer: true) do
    associations do
      has_many :access_tokens
      has_many :addresses
      has_many :orders
    end
  end
end
