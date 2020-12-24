# frozen_string_literal: true

class ApiKeyRepo < ROM::Repository[:api_keys]

  def by_id(id)
    api_keys.by_pk(id).one!
  end

  def generate()
    api_keys.command(:create).call(api_key: SecureRandom.hex)
  end

end
