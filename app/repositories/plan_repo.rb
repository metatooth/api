# frozen_string_literal: true

class PlanRepo < ROM::Repository[:plans]
  def plan_with_revisions
    plans.combine(:revisions)
  end
end
