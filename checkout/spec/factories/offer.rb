# frozen_string_literal: true

FactoryBot.define do
  factory :offer do
    offer_type { Offer.offer_types.keys.sample }
    adjustment_type { Offer.adjustment_types.keys.sample }
    quantity_to_buy { 1 }
    quantity_to_get { 1 }
    amount { 1 }
    products { [association(:product)] }
  end
end
