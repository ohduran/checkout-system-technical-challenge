# frozen_string_literal: true

# Controller for /line_items namespace
class LineItemsController < ApplicationController
  def create
    create_params = LineItems::CreateContract.validate!(params.to_unsafe_h)
    @line_item = LineItem.create!(create_params)

    render :create, formats: :json
  rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid
    raise ApiErrors::ValidationError
  end
end
