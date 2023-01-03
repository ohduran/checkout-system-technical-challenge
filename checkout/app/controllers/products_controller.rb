# frozen_string_literal: true

# Controller for /products namespace
class ProductsController < ApplicationController
  def create
    create_params = Products::CreateContract.validate!(params.to_unsafe_h)
    @product = Product.create(create_params)

    render :create, formats: :json
  end

  def index
    @products = Product.includes([:offers]).all
    render :index, formats: :json
  end

  def show
    @product = Product.find(params[:id])
    render :show, formats: :json
  end
end
