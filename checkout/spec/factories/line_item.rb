FactoryBot.define do
  factory :line_item do
    quantity { Faker::Number.number }
    product
    basket
  end
end
