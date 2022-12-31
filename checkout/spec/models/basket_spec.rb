# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Basket, type: :model do
  let!(:basket) { create(:basket) }

  describe 'line items validation' do
    let(:product) { create(:product) }
    let(:line_item) { build(:line_item, product: product) }

    it 'prevents the line item from being added to the basket' do
      expect { basket.line_items << line_item }.to(change { basket.line_items.count }.from(0).to(1))
      expect { basket.line_items << line_item }.to_not(change { basket.line_items.count })
    end
  end

  describe '#total' do
    let(:product1) { create(:product) }
    let(:product2) { create(:product) }

    context 'and there is no special discount' do
      let!(:line_item1) { create(:line_item, basket: basket, product: product1) }
      let!(:line_item2) { create(:line_item, basket: basket, product: product2) }
      it 'calculates total as price times quantity' do
        expect(basket.reload.total).to eq(
          line_item1.quantity * product1.price + line_item2.quantity * product2.price
        )
      end
    end

    context 'and there is a Buy1Get1 discount on product1' do
      let!(:line_item1) { create(:line_item, basket: basket, product: product1, quantity: 2) }
      let!(:line_item2) { create(:line_item, basket: basket, product: product2) }

      let!(:offer) do
        create(:offer,
               offer_type: :buyxgetx,
               adjustment_type: :percentage,
               quantity_to_buy: 1,
               quantity_to_get: 1,
               amount: 100,
               products: [product1])
      end
      it 'calculates total as price times quantity minus the free item' do
        expect(basket.reload.total).to eq(
          (line_item1.quantity - 1) * product1.price + line_item2.quantity * product2.price
        )
      end
    end

    context 'and there is a Buy1Get1 discount on product1 and product2' do
      let!(:line_item1) { create(:line_item, basket: basket, product: product1, quantity: 2) }
      let!(:line_item2) { create(:line_item, basket: basket, product: product2, quantity: 2) }

      let!(:offer1) do
        create(:offer,
               offer_type: :buyxgetx,
               adjustment_type: :percentage,
               quantity_to_buy: 1,
               quantity_to_get: 1,
               amount: 100,
               products: [product1])
      end
      let!(:offer2) do
        create(:offer,
               offer_type: :buyxgetx,
               adjustment_type: :percentage,
               quantity_to_buy: 1,
               quantity_to_get: 1,
               amount: 100,
               products: [product2])
      end
      it 'calculates total as price times quantity minus the free items' do
        expect(basket.reload.total).to eq(
          (line_item1.quantity - 1) * product1.price + (line_item2.quantity - 1) * product2.price
        )
      end
    end
  end
end
