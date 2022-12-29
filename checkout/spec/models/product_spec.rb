require 'rails_helper'

RSpec.describe Product, type: :model do
  context 'before creation' do
    it 'must have name, code and price' do
      expect { Product.create! }.to raise_error(ActiveRecord::RecordInvalid)
      expect { Product.create!(name: 'Green Tea', code: 'GR1') }.to raise_error(ActiveRecord::RecordInvalid)
      expect { Product.create!(name: 'Green Tea', price: 3.11) }.to raise_error(ActiveRecord::RecordInvalid)
      expect(Product.create!(name: 'Green Tea', code: 'GR1', price: 3.11)).to be
    end

    it 'must have price greater than or equal to 0' do
      expect { Product.create!(name: 'Green Tea', code: 'GR1', price: -3) }.to raise_error(ActiveRecord::RecordInvalid)
      expect(Product.create!(name: 'Green Tea', code: 'GR1', price: 0)).to be
    end

    it 'cannot have price that is not a number' do
      expect do
        Product.create!(name: 'Green Tea', code: 'GR1', price: 'test')
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
