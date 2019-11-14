# frozen_string_literal: true

FactoryBot.use_parent_strategy = false

FactoryBot.define do
  sequence :email do |n|
    "user#{n}-#{Time.now.to_i}@example.com"
  end

  sequence :name do |n|
    "name #{n}"
  end

  factory :api_key do
    api_key { 'RandomKey' }
    active { true }
    created_at { DateTime.now }
    updated_at { DateTime.now }
  end

  factory :address, aliases: [:location] do
    name
    firm { 'Metatooth LLC' }
    address1 { '30 Forest Ave' }
    city { 'Swampscott' }
    state { 'MA' }
    zip5 { '01907' }
    zip4 { '2321' }
    created_at { DateTime.now }
    updated_at { DateTime.now }
  end

  factory :account do
    name
    created_at { DateTime.now }
    updated_at { DateTime.now }
  end

  factory :user do
    email
    name
    type { 'User' }
    account
    created_at { DateTime.now }
    updated_at { DateTime.now }

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

  factory :customer do
    name
    account
    created_at { DateTime.now }
    updated_at { DateTime.now }
  end

  factory :order do
    customer
    created_at { DateTime.now }
    updated_at { DateTime.now }
  end

  factory :order_item do
    order
    created_at { DateTime.now }
    updated_at { DateTime.now }
  end

  factory :invoice do
    created_at { DateTime.now }
    updated_at { DateTime.now }
  end
end
