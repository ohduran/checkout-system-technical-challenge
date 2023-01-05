# frozen_string_literal: true

# Each basket consist of a series of LineItems
class LineItem < ApplicationRecord
  include Memery

  attribute :quantity, :integer

  belongs_to :basket
  belongs_to :product

  validates :quantity,
            presence: true,
            numericality: { greater_than_or_equal_to: 0, only_integer: true }

  def total
    quantity * product.price - discounts
  end

  def discounts
    return 0 unless applicable_offers

    applicable_offers.sum { |offer| offer.discount(quantity: quantity, product: product) }
  end

  memoize def applicable_offers
    product.offers.that_apply_to(self)
  end
end
