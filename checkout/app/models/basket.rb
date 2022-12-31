# frozen_string_literal: true

# Each user is assigned a basket; they will purchase products that will get recorded as LineItems
class Basket < ApplicationRecord
  has_many :line_items
  has_many :products, through: :line_items
end
