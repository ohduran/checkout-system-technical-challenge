# frozen_string_literal: true

module Products
  # Contract handling creation parameters for #create
  class CreateContract < ApplicationContract
    params do
      required(:code).filled(:string)
      required(:name).filled(:string)
      required(:price).value(:decimal)
    end
  end
end
