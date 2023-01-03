# frozen_string_literal: true

# Controller for /offers namespace
class OffersController < ApplicationController
  def create
    create_params = Offers::CreateContract.validate!(params.to_unsafe_h)
    Product.find_by_id(create_params[:product_ids])

    @offer = Offer.create!(create_params)

    render :create, formats: :json
  rescue ActiveRecord::RecordNotFound
    raise ApiErrors::ValidationError
  end

  def index
    @offers = Offer.includes([:products]).all
    render :index, formats: :json
  end

  def show
    @offer = Offer.find(params[:id])
    render :show, formats: :json
  end
end
