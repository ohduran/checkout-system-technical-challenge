require 'rails_helper'

RSpec.describe Product, type: :model do
  context 'before creation' do
    it 'must have name, code and price' do
      expect { Product.create! }.to raise_error(ActiveRecord::RecordInvalid)
      expect do
        Product.create!(name: Faker::Food.dish,
                        code: Faker::Alphanumeric.alphanumeric)
      end.to raise_error(ActiveRecord::RecordInvalid)
      expect do
        Product.create!(name: Faker::Food.dish,
                        price: Faker::Alphanumeric.alphanumeric)
      end.to raise_error(ActiveRecord::RecordInvalid)
      expect(Product.create!(name: Faker::Food.dish, code: Faker::Alphanumeric.alphanumeric,
                             price: Faker::Number.decimal(l_digits: 2))).to be
    end

    it 'must have price greater than or equal to 0' do
      expect do
        Product.create!(name: Faker::Food.dish, code: Faker::Alphanumeric.alphanumeric,
                        price: -3)
      end.to raise_error(ActiveRecord::RecordInvalid)
      expect(Product.create!(name: Faker::Food.dish, code: Faker::Alphanumeric.alphanumeric, price: 0)).to be
    end

    it 'cannot have price that is not a number' do
      expect do
        Product.create!(name: Faker::Food.dish, code: Faker::Alphanumeric.alphanumeric,
                        price: Faker::Alphanumeric.alphanumeric).to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
