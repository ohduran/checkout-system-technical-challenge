# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Offers', type: :request do
  describe 'GET /offers' do
    let(:url) { offers_url }
    let(:parsed_json) { JSON.parse(response.body) }

    let!(:offers) { create_list(:offer, 5) }

    context 'when requesting all offers' do
      it 'should list all offers' do
        get(url)
        expect(response).to be_successful

        expect(parsed_json.length).to eq(5)
        parsed_json.each do |actual_offer|
          expect(actual_offer['id']).to be_a_kind_of(Integer)
          expect(actual_offer['products']).to be_a_kind_of(Array)
        end
      end
    end
  end

  describe 'GET /offers/<id>' do
    let(:url) { offer_url(offer.id) }
    let(:parsed_json) { JSON.parse(response.body) }

    let!(:offers) { create_list(:offer, 4) }

    let(:products) { create_list(:product, 5) }
    let!(:offer) { create(:offer, products: products) }

    context 'when requesting a certain offer' do
      it 'should list all offers' do
        get(url)
        expect(response).to be_successful
        expect(parsed_json['id']).to be_a_kind_of(Integer)
        expect(parsed_json['products']).to be_a_kind_of(Array)
        expect(parsed_json['products'].length).to eq(5)
      end
    end
  end

  describe 'POST /offers' do
    let(:url) { offers_url }
    let(:parsed_json) { JSON.parse(response.body) }

    context 'when creating a new offer with bad data' do
      it 'should return a 400 response' do
        expect { post(url, params: {}) }.not_to(change { Offer.count })
        expect(response).to have_http_status(:bad_request)

        expect(parsed_json['error']).to be
      end
    end

    context 'when creating a new offer with a non existing product' do
      let(:params) do
        {
          offer_type: Offer.offer_types['buyxgetx'],
          adjustment_type: Offer.adjustment_types[:percentage],
          quantity_to_buy: 2,
          quantity_to_get: 1,
          amount: 100,
          product_ids: ['test']
        }.with_indifferent_access
      end
      it 'should return a 400 response' do
        post(url, params: params)

        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when creating a new offer' do
      let(:product) { create(:product) }
      let(:params) do
        {
          offer_type: Offer.offer_types['buyxgetx'],
          adjustment_type: Offer.adjustment_types[:percentage],
          quantity_to_buy: 2,
          quantity_to_get: 1,
          amount: 100,
          product_ids: [product.id]
        }.with_indifferent_access
      end
      it 'should return a barebones offer' do
        post(url, params: params)

        expect(response).to be_successful
        expect(Offer.count).to eq(1)
        expect(parsed_json['id']).to be_a_kind_of(Integer)
        expect(parsed_json['id']).to eq(Offer.first.id)
        expect(parsed_json['products']).to be_a_kind_of(Array)
        expect(parsed_json['products'].length).to eq(1)
      end
    end
  end
end
