# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Baskets', type: :request do
  describe 'GET /baskets' do
    let(:url) { baskets_url }
    let(:parsed_json) { JSON.parse(response.body) }

    let!(:baskets) { create_list(:basket, 5) }

    context 'when requesting all baskets' do
      before do
        baskets.each { |basket| create_list(:line_item, 4, basket: basket) }
      end
      it 'should list all baskets' do
        get(url)
        expect(response).to be_successful

        expect(parsed_json.length).to eq(5)
        parsed_json.each do |actual_basket|
          expect(actual_basket['id']).to be_a_kind_of(Integer)
          expect(actual_basket['line_items']).to be_a_kind_of(Array)
          expect(actual_basket['line_items'].length).to eq(4)
        end
      end
    end
  end

  describe 'GET /baskets/<id>' do
    let(:url) { basket_url(basket.id) }
    let(:parsed_json) { JSON.parse(response.body) }

    let!(:baskets) { create_list(:basket, 4) }
    let!(:basket) { create(:basket) }

    context 'when requesting a certain basket' do
      before do
        create_list(:line_item, 4, basket: basket)
      end
      it 'should list all baskets' do
        get(url)
        expect(response).to be_successful
        expect(parsed_json['id']).to be_a_kind_of(Integer)
        expect(parsed_json['line_items']).to be_a_kind_of(Array)
        expect(parsed_json['line_items'].length).to eq(4)
      end
    end
  end
end
