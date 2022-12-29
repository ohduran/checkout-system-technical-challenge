class LineItem < ApplicationRecord
  attribute :quantity

  belongs_to :basket
  belongs_to :product

  validates :quantity,
            presence: true,
            numericality: { greater_than_or_equal_to: 0, only_integer: true }

  def total
    quantity * product.price
  end
end
