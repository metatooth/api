FactoryBot.use_parent_strategy = false

FactoryBot.define do
  sequence :email do |n|
    "user#{n}@example.com"
  end

  sequence :name do |n|
    "name #{n}"
  end

  sequence :locator do |n|
    "#{n}"
  end

  factory :user do
    locator
    email
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