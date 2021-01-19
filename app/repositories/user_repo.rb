# frozen_string_literal: true

# Conveniences for the user repository.
class UserRepo < ROM::Repository[:users]
  commands :create, update: :by_pk

  def by_id(id)
    users.by_pk(id).one!
  end

  def delete(id)
    update(id, deleted: true, deleted_at: DateTime.now)
  end

  def query(conditions)
    users.where(conditions).to_a
  end
end
