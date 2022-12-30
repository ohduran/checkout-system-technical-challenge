FactoryBot.define do
  factory :offer do
    offer_type { Faker::Enum.random(Task.offer_types) }
    adjustment_type { Faker::Enum.random(Task.adjustment_types) }
    quantity_to_buy { 1 }
    quantity_to_get { 1 }
    amount { 1 }
    products { [association(:product)] }
  end
end
