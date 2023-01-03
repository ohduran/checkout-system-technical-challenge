# frozen_string_literal: true

module LineItems
  # Contract handling creation parameters for #create
  class CreateContract < ApplicationContract
    params do
      required(:product_id).filled(:integer)
      required(:quantity).filled(:integer)
      required(:basket_id).value(:integer)
    end
  end
end
