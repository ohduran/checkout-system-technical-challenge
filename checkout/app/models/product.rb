class Product < ApplicationRecord
  attribute :code
  attribute :name
  attribute :price

  has_many :line_items
  has_many :baskets, through: :line_items

  validates :name, :code, :price, presence: true

  validates :price,
            numericality: true,
            comparison: { greater_than_or_equal_to: 0 }
end
