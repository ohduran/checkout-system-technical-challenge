# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'LineItems', type: :request do
  describe 'POST /line_items' do
    let(:url) { line_items_url }
    let(:parsed_json) { JSON.parse(response.body) }

    context 'when creating a new line_item with bad data' do
      it 'should return a 400 response' do
        expect { post(url, params: {}) }.not_to(change { LineItem.count })
        expect(response).to have_http_status(:bad_request)

        expect(parsed_json['error']).to be
      end
    end

    context 'when creating a new line item with a non existing product' do
      let(:basket) { create(:basket) }
      let(:params) do
        {
          product_id: 13,
          basket_id: basket.id,
          quantity: 1
        }.with_indifferent_access
      end
      it 'should return a 400 response' do
        post(url, params: params)

        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when creating a new line item with a non existing basket' do
      let(:product) { create(:product) }
      let(:params) do
        {
          product_id: product.id,
          basket_id: 13,
          quantity: 1
        }.with_indifferent_access
      end
      it 'should return a 400 response' do
        post(url, params: params)

        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when creating a new line item' do
      let(:product) { create(:product) }
      let(:basket) { create(:basket) }
      let(:params) do
        {
          product_id: product.id,
          basket_id: basket.id,
          quantity: 42
        }.with_indifferent_access
      end
      it 'should return the created line item' do
        post(url, params: params)

        expect(response).to be_successful
        expect(LineItem.count).to eq(1)
        expect(parsed_json['id']).to be_a_kind_of(Integer)
        expect(parsed_json['id']).to eq(LineItem.first.id)
        expect(parsed_json['quantity']).to eq(params[:quantity])

        expect(parsed_json['product']).to be
        expect(parsed_json['product']['id']).to eq(product.id)

        expect(parsed_json['basket']).to be
        expect(parsed_json['basket']['id']).to eq(product.id)
      end
    end
  end
end
