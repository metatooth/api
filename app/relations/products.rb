# frozen_string_literal: true

class Products < ROM::Relation[:sql]
  schema(:products, infer: true) do
  end
end
