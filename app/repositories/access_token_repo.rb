class AccessTokenRepo < ROM::Repository[:access_tokens]

  def query(conditions)
    access_tokens.where(conditions).to_a
  end

end
