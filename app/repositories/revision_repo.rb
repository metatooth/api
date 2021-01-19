# frozen_string_literal: true

class RevisionRepo < ROM::Repository[:revisions]
  def by_locator(locator)
    revisions.where(locator: locator).one!
  end
end
