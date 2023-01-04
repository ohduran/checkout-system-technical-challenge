# frozen_string_literal: true

FactoryBot.define do
  factory :line_item do
    quantity { Faker::Number.number }
    product
    basket

    trait :with_offer do
      after(:create) do |line_item, _evaluator|
        line_item.product.offers << create(:offer)
      end
    end
  end
end
