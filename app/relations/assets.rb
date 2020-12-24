class Assets < ROM::Relation[:sql]
  schema(infer: true)

  def by_created_at(from, to)
    where { (created_at > from) & (created_at < to) }
  end
end
