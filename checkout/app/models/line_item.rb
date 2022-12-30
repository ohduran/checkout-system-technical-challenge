class LineItem < ApplicationRecord
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

    discount_amount = 0
    applicable_offers.each do |offer|
      case offer.adjustment_type
      when 'percentage'
        # We discount the price of the product times the offer percentage amount
        # and reduce the counter by quantity_to_buy + quantity_to_get
        # until the counter cannot be reduced anymore
        counter = quantity
        while counter >= offer.quantity_to_buy + offer.quantity_to_get
          discount_amount += product.price * offer.amount / 100
          counter -= offer.quantity_to_buy + offer.quantity_to_get
        end

      else
        raise StandardError
      end
    end

    discount_amount
  end

  def applicable_offers
    product.offers.where('quantity_to_buy + quantity_to_get <= ?', quantity)
  end
end
