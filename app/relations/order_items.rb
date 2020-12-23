class OrderItems < ROM::Relation[:sql]
  schema(:order_items, infer: true) do
    associations do
      belongs_to :order
      belongs_to :product
    end
  end
end
