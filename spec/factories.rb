# frozen_string_literal: true

FactoryBot.use_parent_strategy = false

FactoryBot.define do
  sequence :email do |n|
    "user#{n}@example.com"
  end

  sequence :name do |n|
    "name #{n}"
  end

  sequence :locator, &:to_s

  factory :api_key do
    api_key { 'RandomKey' }
    active { true }
  end

  factory :user do
    locator
    email
    name
    type { 'User' }

    trait :confirmation_redirect_url do
      confirmation_token { '123' }
      confirmation_redirect_url { 'http://google.com' }
    end

    trait :confirmation_no_redirect_url do
      confirmation_token { '123' }
      confirmation_redirect_url { nil }
    end

    trait :reset_password do
      reset_password_token { '123' }
      reset_password_redirect_url { 'http://example.com?some=params' }
      reset_password_sent_at { Time.now }
    end

    trait :reset_password_no_params do
      reset_password_token { '123' }
      reset_password_redirect_url { 'http://example.com' }
      reset_password_sent_at { Time.now }
    end
  end

  factory :account do
    locator
    name
  end

  factory :customer do
    locator
    name
    account
  end

  factory :address do
    locator
  end

  factory :order do
    locator
    customer
  end

  factory :order_item do
    locator
    order
  end

  factory :invoice do
    locator
  end
end
