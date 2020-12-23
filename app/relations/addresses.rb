class Addresses < ROM::Relation[:sql]
  schema(:addresses, infer: true) do
    associations do
      belongs_to :user
    end
  end  
end
