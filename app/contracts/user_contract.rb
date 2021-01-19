# frozen_string_literal: true

class UserContract < Dry::Validation::Contract
  params do
    required(:email).filled(:string)
  end

  rule(:email) do
    key.failure('has invalid format') unless /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.match?(value)
  end
end
