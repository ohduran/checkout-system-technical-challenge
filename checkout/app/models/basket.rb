# frozen_string_literal: true

# Each user is assigned a basket; they will purchase products that will get recorded as LineItems
class Basket < ApplicationRecord
  has_many :line_items
  has_many :products, through: :line_items

  validate :line_items_cannot_belong_to_the_same_product

  def total
    line_items.sum(&:total)
  end

  private

  def line_items_cannot_belong_to_the_same_product
    product_ids = line_items.map(&:product_id)

    return unless product_ids.uniq.length < product_ids.length

    errors.add(:line_items, 'cannot belong to the same product')
  end
end
