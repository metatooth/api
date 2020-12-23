class Revisions < ROM::Relation[:sql]
  schema(:revisions, infer: true) do
    associations do
      belongs_to :plan
    end
  end
end
