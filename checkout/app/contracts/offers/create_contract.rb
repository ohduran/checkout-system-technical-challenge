# frozen_string_literal: true

module Offers
  # Contract handling creation parameters for #create
  class CreateContract < ApplicationContract
    params do
      required(:offer_type).filled(:string)
      required(:adjustment_type).filled(:string)
      required(:quantity_to_buy).value(:integer)
      required(:product_ids).each do
        str?
      end
      optional(:quantity_to_get).value(:integer)

      required(:amount).value(:decimal)
    end
  end
end
