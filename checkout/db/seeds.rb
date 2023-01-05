# frozen_string_literal: true

# Test data according to the README gets created as part of the seed.

require 'factory_bot_rails'
extend FactoryBot::Syntax::Methods

# Create the products

# | Product Code | Name | Price |
# | GR1 |  Green Tea | 3.11€ |
gr1 = create(:product, code: 'GR1', name: 'Green Tea', price: 3.11)

# | SR1 |  Strawberries | 5.00 € |
sr1 = create(:product, code: 'SR1', name: 'Strawberries', price: 5)

# | CF1 |  Coffee | 11.23 € |
cf1 = create(:product, code: 'CF1', name: 'Coffee', price: 11.23)

# Create the offers

# - The CEO is a big fan of buy-one-get-one-free offers and green tea.
create(:offer,
       offer_type: :buyxgetx,
       adjustment_type: :percentage,
       quantity_to_buy: 1,
       quantity_to_get: 1,
       amount: 100,
       products: [gr1])

# - The COO, though, likes low prices and wants people buying strawberries to get a price  discount for bulk purchases.
# If you buy 3 or more strawberries, the price should drop to 4.50€.
create(:offer,
       offer_type: :buyxalldropx,
       adjustment_type: :value,
       quantity_to_buy: 3,
       quantity_to_get: nil,
       amount: 0.5,
       products: [sr1])

# - The VP of Engineering is a coffee addict.
# If you buy 3 or more coffees, the price of all coffees should drop to 2/3 of the original price.
create(:offer,
       offer_type: :buyxalldropx,
       adjustment_type: :percentage,
       quantity_to_buy: 3,
       quantity_to_get: nil,
       amount: 33,
       products: [cf1])

# Create the baskets
basket1 = create(:basket)
basket2 = create(:basket)
basket3 = create(:basket)

# Create the line items for each basket

# | Basket | Total price expected |
# | GR1,GR1 |  3.11€ |
create(:line_item, basket: basket1, product: gr1, quantity: 2)

# | SR1,SR1,GR1,SR1 |  16.61€ |
create(:line_item, basket: basket2, product: sr1, quantity: 3)
create(:line_item, basket: basket2, product: gr1, quantity: 1)

# | GR1,CF1,SR1,CF1,CF1 |  30.57€ |
create(:line_item, basket: basket3, product: gr1, quantity: 1)
create(:line_item, basket: basket3, product: cf1, quantity: 3)
create(:line_item, basket: basket3, product: sr1, quantity: 1)
