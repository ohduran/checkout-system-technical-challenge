# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Offer, type: :model do
  context 'when calculating discount' do
    context 'when there is a buy-one-get-one-free on Product GR1' do
      let(:product) { create(:product, code: 'GR1') }
      let!(:offer) do
        create(:offer,
               offer_type: :buyxgetx,
               adjustment_type: :percentage,
               quantity_to_buy: 1,
               quantity_to_get: 1,
               amount: 100,
               products: [product])
      end
      context 'and there is one item' do
        it 'calculates discount as zero' do
          expect(offer.discount(quantity: 1, product: product)).to eq(0)
        end
      end
      context 'and there are two items' do
        it 'calculates discount as the price of the product' do
          expect(offer.discount(quantity: 2, product: product)).to eq(product.price)
        end
      end
      context 'and there are three items' do
        it 'calculates discount as the price of the product' do
          expect(offer.discount(quantity: 3, product: product)).to eq(product.price)
        end
      end
      context 'and there are four items' do
        it 'calculates discount as two times the price of the product' do
          expect(offer.discount(quantity: 4, product: product)).to eq(2 * product.price)
        end
      end
    end

    context 'when there is a 50 cent discount on all strawberries when you buy 3 or more' do
      let(:product) { create(:product, code: 'SR1') }
      let!(:offer) do
        create(:offer,
               offer_type: :buyxalldropx,
               adjustment_type: :value,
               quantity_to_buy: 3,
               quantity_to_get: nil,
               amount: 0.5,
               products: [product])
      end
      context 'and there are two items' do
        it 'calculates discount as zero' do
          expect(offer.discount(quantity: 2, product: product)).to eq(0)
        end
      end
      context 'and there are three items' do
        it 'calculates discount as three times the offer amount' do
          expect(offer.discount(quantity: 3, product: product)).to eq(3 * offer.amount)
        end
      end
      context 'and there are four items' do
        it 'calculates discount as four times the offer amount' do
          expect(offer.discount(quantity: 4, product: product)).to eq(4 * offer.amount)
        end
      end
    end

    context 'when there is a 66% discount on all coffees when you buy 3 or more' do
      let(:product) { create(:product, code: 'CF1') }
      let!(:offer) do
        create(:offer,
               offer_type: :buyxalldropx,
               adjustment_type: :percentage,
               quantity_to_buy: 3,
               quantity_to_get: nil,
               amount: 66,
               products: [product])
      end
      context 'and there are two items' do
        it 'calculates discount as zero' do
          expect(offer.discount(quantity: 2, product: product)).to eq(0)
        end
      end
      context 'and there are three items' do
        it 'calculates discount as three times the offer amount as a percentage of the price' do
          expect(offer.discount(quantity: 3, product: product)).to eq(3 * offer.amount * product.price / 100)
        end
      end
      context 'and there are four items' do
        it 'calculates discount as four times the offer amount as a percentage of the price' do
          expect(offer.discount(quantity: 4, product: product)).to eq(4 * offer.amount * product.price / 100)
        end
      end
    end
  end
end
