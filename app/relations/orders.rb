class Orders < ROM::Relation[:sql]
  schema(:orders, infer: true) do
    associations do
      belongs_to :user
      belongs_to :address, as: :bill
      belongs_to :address, as: :ship
      has_many :order_items
    end
  end

  def by_user(user)
    where { (user_id = user.id) }
  end
end
