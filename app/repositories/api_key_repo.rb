class ApiKeyRepo < ROM::Repository[:api_keys]

  def by_id(id)
    api_keys.by_pk(id).one!
  end

end
