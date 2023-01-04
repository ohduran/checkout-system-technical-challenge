# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Products', type: :request do
  describe 'GET /products' do
    let(:url) { products_url }
    let(:parsed_json) { JSON.parse(response.body) }

    let!(:products) { create_list(:product, 5) }

    context 'when requesting all products' do
      before do
        products.each { |product| create_list(:offer, 4, products: [product]) }
      end
      it 'should list all products' do
        get(url)
        expect(response).to be_successful

        expect(parsed_json.length).to eq(5)
        parsed_json.each do |actual_product|
          expect(actual_product['id']).to be_a_kind_of(Integer)
          expect(actual_product['offers']).to be_a_kind_of(Array)
          expect(actual_product['offers'].length).to eq(4)
        end
      end
    end
  end

  describe 'GET /products/<id>' do
    let(:url) { product_url(product.id) }
    let(:parsed_json) { JSON.parse(response.body) }

    let!(:products) { create_list(:product, 4) }
    let!(:product) { create(:product) }

    context 'when requesting a certain product' do
      before do
        create_list(:offer, 4, products: [product])
      end
      it 'should list all products' do
        get(url)
        expect(response).to be_successful
        expect(parsed_json['id']).to be_a_kind_of(Integer)
        expect(parsed_json['offers']).to be_a_kind_of(Array)
        expect(parsed_json['offers'].length).to eq(4)
      end
    end
  end

  describe 'POST /products' do
    let(:url) { products_url }
    let(:parsed_json) { JSON.parse(response.body) }

    context 'when creating a new product with bad data' do
      it 'should return a 400 response' do
        expect { post(url, params: {}) }.not_to(change { Product.count })
        expect(response).to have_http_status(:bad_request)

        expect(parsed_json['error']).to be
      end
    end

    context 'when creating a new product' do
      let(:params) do
        {
          code: 'CS1',
          name: 'Caesar Salad',
          price: 12.25
        }.with_indifferent_access
      end
      it 'should return a barebones product' do
        post(url, params: params)

        expect(response).to be_successful
        expect(Product.count).to eq(1)
        expect(parsed_json['id']).to be_a_kind_of(Integer)
        expect(parsed_json['id']).to eq(Product.first.id)
        expect(parsed_json['offers']).to be_a_kind_of(Array)
        expect(parsed_json['offers'].length).to eq(0)
      end
    end
  end
end
