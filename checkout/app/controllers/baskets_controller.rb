# frozen_string_literal: true

# Controller for /baskets namespace
class BasketsController < ApplicationController
  def create
    create_params = Baskets::CreateContract.validate!(params)
    @basket = Basket.create(create_params)

    render :create, formats: :json
  end

  def index
    @baskets = Basket.includes([:line_items]).all
    render :index, formats: :json
  end

  def show
    @basket = Basket.find(params[:id])
    render :show, formats: :json
  end
end
