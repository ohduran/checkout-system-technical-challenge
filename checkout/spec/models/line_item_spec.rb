# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LineItem, type: :model do
  context 'before creation' do
    let(:basket) { create(:basket) }
    let(:product) { create(:product) }
    it 'must have basket, LineItem and quantity' do
      expect { LineItem.create! }.to raise_error(ActiveRecord::RecordInvalid)
      expect { LineItem.create!(product: product, basket: basket) }.to raise_error(ActiveRecord::RecordInvalid)
      expect { LineItem.create!(product: product, quantity: 3) }.to raise_error(ActiveRecord::RecordInvalid)
      expect(LineItem.create!(product: product, basket: basket, quantity: 3)).to be
    end

    it 'must have price greater than or equal to 0' do
      expect do
        LineItem.create!(product: product, basket: basket, quantity: -3)
      end.to raise_error(ActiveRecord::RecordInvalid)
      expect(LineItem.create!(product: product, basket: basket, quantity: 0)).to be
    end

    it 'cannot have quantity that is not a number' do
      expect do
        LineItem.create!(product: product, basket: basket, quantity: Faker::Alphanumeric.alphanumeric)
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  context 'when calculating total' do
    context 'and there is no special discount' do
      let(:product) { create(:product) }
      let(:line_item) { create(:line_item, product: product) }
      it 'calculates total as price times quantity' do
        expect(line_item.total).to eq(line_item.quantity * product.price)
      end
    end

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
        let(:line_item) { create(:line_item, product: product, quantity: 1) }
        it 'calculates total as just one time the price of the product' do
          expect(line_item.total).to eq(line_item.quantity * product.price)
        end
      end
      context 'and there are two items' do
        let(:line_item) { create(:line_item, product: product, quantity: 2) }
        it 'calculates total as just one time the price of the product' do
          expect(line_item.total).to eq(1 * product.price)
        end
      end
      context 'and there are three items' do
        let(:line_item) { create(:line_item, product: product, quantity: 3) }
        it 'calculates total as just two times the price of the product' do
          expect(line_item.total).to eq(2 * product.price)
        end
      end
      context 'and there are four items' do
        let(:line_item) { create(:line_item, product: product, quantity: 4) }
        it 'calculates total as just two times the price of the product' do
          expect(line_item.total).to eq(2 * product.price)
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
        let(:line_item) { create(:line_item, product: product, quantity: 2) }
        it 'calculates total with the normal price' do
          expect(line_item.total).to eq(line_item.quantity * product.price)
        end
      end
      context 'and there are three items' do
        let(:line_item) { create(:line_item, product: product, quantity: 3) }
        it 'calculates total with the reduced price' do
          expect(line_item.total).to eq(line_item.quantity * (product.price - offer.amount))
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
        let(:line_item) { create(:line_item, product: product, quantity: 2) }
        it 'calculates total with the normal price' do
          expect(line_item.total).to eq(line_item.quantity * product.price)
        end
      end
      context 'and there are three items' do
        let(:line_item) { create(:line_item, product: product, quantity: 3) }
        it 'calculates total with the reduced price' do
          expect(line_item.total).to eq(line_item.quantity * product.price * (1 - offer.amount / 100))
        end
      end
    end
  end
end
