class Offer < ApplicationRecord
  attribute :offer_type, :string
  attribute :adjustment_type, :string

  enum offer_types: {
    buyxgetx: 'BUY_X_GET_X'
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

  validates :offer_type, :adjustment_type, :quantity_to_buy, :quantity_to_get, :amount, :products, presence: true

  validates :quantity_to_buy, numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates :quantity_to_get, numericality: { greater_than_or_equal_to: 1, only_integer: true }
end
