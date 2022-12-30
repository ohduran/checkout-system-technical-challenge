class Product < ApplicationRecord
  attribute :code, :string
  attribute :name, :string
  attribute :price, :decimal

  has_many :line_items
  has_many :baskets, through: :line_items
  has_and_belongs_to_many :offers

  validates :name, :code, :price, presence: true

  validates :price,
            numericality: true,
            comparison: { greater_than_or_equal_to: 0 }
end
