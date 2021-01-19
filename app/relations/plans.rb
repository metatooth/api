# frozen_string_literal: true

class Plans < ROM::Relation[:sql]
  schema(:plans, infer: true) do
    associations do
      has_many :revisions
    end
  end
end
