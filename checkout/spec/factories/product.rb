# frozen_string_literal: true

FactoryBot.define do
  factory :product do
    name { Faker::Food.dish }
    code { Faker::Alphanumeric.alphanumeric.upcase }
    price { Faker::Number.decimal(l_digits: 2) }
  end
end
