# frozen_string_literal: true

# Some products may offer a discount and the user may end up paying less than full price.
class Offer < ApplicationRecord
  attribute :offer_type, :string
  attribute :adjustment_type, :string

  enum offer_types: {
    buyxgetx: 'BUY_X_GET_X',
    buyxalldropx: 'BUY_X_ALL_DROP_X'
  }

  enum adjustment_types: {
    percentage: 'PERCENTAGE',
    value: 'VALUE'
  }

  # The number of products the buyer
  # needs to buy in order to qualify for the offer
  # will get at the adjusted rate once they qualify.
  attribute :quantity_to_buy, :integer
  attribute :quantity_to_get, :integer

  # The discount rate applied
  attribute :amount, :decimal

  # The list of products that qualify
  # as quantity to buy
  has_and_belongs_to_many :products

  validates :offer_type, :adjustment_type, :quantity_to_buy, :amount, :products, presence: true

  validates :quantity_to_buy, numericality: { greater_than_or_equal_to: 1, only_integer: true }

  # The offer gets applied only to eligible line_items
  scope :that_apply_to, ->(line_item) { where('quantity_to_buy <= ?', line_item.quantity) }

  def discount(quantity:, product:)
    return 0 unless products.include?(product)
    return 0 unless quantity >= quantity_to_buy # weaker condition than in buyxgetx

    discount_amount = 0
    case adjustment_type
    when 'percentage'
      discount = product.price * amount / 100
    when 'value'
      discount = amount
    else
      raise StandardError
    end

    case offer_type
    when 'buyxgetx'
      # validate that quantity_to_buy is strictly greater than quantity
      return 0 unless quantity > quantity_to_buy
      # validate that quantity_to_get is present for buyxgetx offers
      return 0 unless quantity_to_get.is_a?(Integer) && quantity_to_get.positive?

      # Given that the quantities are integers, dividing quantity
      # by the sum of _to_buy and _to_get does the job nicely.
      # 3 / 2 = 1, 4 / 2 = 2, 5 / 2 = 2.
      # 4 / 3 = 1, 5 / 3 = 1, 6 / 3 = 2.
      discount_amount = quantity / (quantity_to_buy + quantity_to_get) * discount
    when 'buyxalldropx'
      # The discount amount equals the number of items
      # times the individual discount.
      discount_amount = quantity * discount
    else
      raise StandardError
    end

    discount_amount
  end
end
