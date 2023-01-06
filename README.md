# Checkout System

This is a [Rails](https://rubyonrails.org/) application that powers the common use cases for a cash register.

This app will be able to add products to a cart and compute the total price. See objectives and technical specification in the [Technical Specification file](./TECHNICAL_SPECIFICATION.md).

## How to Bring the server up

Make sure that you have [Docker](https://www.docker.com/) installed on your computer.

First, open a terminal, change directory to this project root folder and run `docker-compose build` in order to build the images.

After that, we need to set up the database, run the migrations and preload some seed data that mimics the example baskets in the specification. For that, run the following command:

```sh
docker-compose run --rm checkout bash -c "RAILS_ENV=development rails db:migrate && rails db:seed"
```

Finally, bring the server up with `docker-compose up`. You can interact with the endpoints from any API GUI such as [Postman](https://www.postman.com/).

Notice that by calling http://localhost/baskets, you'll find the example baskets described in the spec. For the second basket, the total differs slightly from the expected value due to the fact that the offer was described in terms of "2/3 of the price", which was implemented as "66%".

## Data Model

The project data model revolves around the Basket model. This model encapsulates a collection of LineItems, and its total is calculated as the sum of the totals of each of those LineItems.

These LineItems reference the Product they're associated with and record the quantity of those products. A Product is simply a record of a product's name, code and price, as it is described in the spec. Two LineItems that reference the same Product cannot belong to the same Basket (see [Basket#line_items_cannot_belong_to_the_same_product](checkout/app/models/basket.rb)). Each LineItem calculates its own total based on the price of the product and any discount that may come from applicable offers for which the line item is eligible (see [LineItem#applicable_offers and LineItem#discounts](checkout/app/models/line_item.rb)).

Products may reference and be referenced by Offers. Heavily inspired by [how offers can be configured in WooCommerce](https://pluginrepublic.com/buy-one-get-one-free-woocommerce/), an Offer model encapsulates the calculations of a discount based on the offer type (for now, there are only "Buy X Get X Free" and "Buy X and the price of all drop X" types), the adjustment type (whether the discount is percentage or value based), the discount amount (the percentage amount or the value amount depending on the adjustment type) the quantity required to buy to qualify for the offer and, when the offer is of type "Buy X Get X", the quantity that get the offer apply.

For example, the straightforward "Buy 1 Get 1 Free" is recorded as an Offer with type "buyxgetx", with an adjustment type "percentage", an amount of 100%, and quantity to buy and quantity to get as 1.

The goal with this settings is to move away from one-off discounts and to attempt at creating a generic framework into which many configurable Offers can apply with little overhead. Initially, I considered the possibility of creating evermore complex offer calculations as first-class functions, but by providing the ability to persist offers in the database, non-technical users are enabled to experiment and tinker away without the need to make changes to the codebase.

Incidentally, by structuring offers this way, a potential use case has been implemented: an offer of the type "Buy 1 Get 50 cents off the second". No tests were included for this as it falls out of the scope.

## Discount Calculation

The first iteration for calculating percentage based offer discounts was this:

```rb
counter = quantity
while counter >= offer.quantity_to_buy + offer.quantity_to_get
    discount_amount += product.price * offer.amount / 100
    counter -= offer.quantity_to_buy + offer.quantity_to_get
end
```

A very crude first iteration that did the job: in order to calculate the amount discounted from the full price, we calculate the number of times by reducing the quantity of items by chunks of quantity to buy + quantity to get, so that for each quantity_to_buy number of items, a number of quantity_to_get items received the discount.

I created some tests for Buy 1 Get 1 to confirm that this worked and, noticing that both quantity_to_buy and quantity_to_get were integers, a second iteration looked like this:

```rb
discount_amount = quantity / (quantity_to_buy + quantity_to_get) * discount
```

As I was writing this, I noticed that this would not work when quantity_to_get was different from 1, that is, offers such as Buy 5 Get 2, because for each quantity_to_buy number of items, a number of quantity_to_get must receive a discount *for each item*. Finally, the last iteration looked like this:

```rb
discount_amount = quantity * quantity_to_get / (quantity_to_buy + quantity_to_get) * discount
```

---

In order to introduce the use case where if you buy 3 or more strawberries, the price should drop to 4.50€, the code should be adapted for the buyxalldropx offer type. Since the offer type and the adjustment type were decoupled from each other, it followed naturally that these must be considered separately.

Hence, the discount amount is now calculated in two parts:

1. Based on the adjustment type, calculate the "discount units", which would be the offer amount for the *value* adjustment type, and the price of the product times the amount percentage for the *percentage* adjustment type.

2. Based on the offer type, calculate the "increments" of discount units that would add up the discount amount. For buyxgetx offer types, the calculation was described above; for buyxalldropx, the calculation is even simpler, as the discount amount would be the units of discount times the number of items, since all items received a discount.

See [Offer#discount](checkout/app/models/offer.rb) for more.

## Why not move logic away from the model?

One valid question that can be raised is whether the logic for the discount calculation could be separated into a different function, or the model validation `line_items_cannot_belong_to_the_same_product` could be split from the LineItem model.

In my opinion, there are two important advantages to keep a "fat model":

- First and foremost, it *binds the language we use to speak about the project with the implementation*. I can still reason in terms familiar to non-technical team members. The way we describe how Baskets, Products, Offers, and LineItems interact with each other need no intermediate DiscountCalculators or LineItemValidators, thus they should not be present in the code. As a consequence, *it improves test readability and discoverability*, since test descriptions are understandable by non-technical team mates, who can contribute to the conversation in the spirit of [Behavior-driven development](https://en.wikipedia.org/wiki/Behavior-driven_development).

- Second, *change amplification and cognitive load*. Should this project grow in complexity, subtle bugs are way easier to introduce if, for instance, the model validation is not tighly coupled with the model itself; otherwise, every time a line item gets added, the developer must keep in mind including the validation as well. The model is then a meaningful gateway into the database, so that operations performed on the model make sense externally without the need to know about internal implementation details.

These arguments informed the decision to [Refactor discount method into Offer model](https://github.com/ohduran/checkout-system-technical-challenge/commit/82e0d96c9351d3b9de8dcfba2755aaf834b14563), [Prevent inconsistencies in Basket](https://github.com/ohduran/checkout-system-technical-challenge/commit/37d2afb6598bcadca651cb3d8a17c4249c09afcf) and [Refactor LineItem#applicable_offers](https://github.com/ohduran/checkout-system-technical-challenge/commit/b7d0d32530e3052ebc0dfdcb715998cdf4ee41f0).

## Extension ideas

Aside from organically introducing Offers with type 'buyxgetx' and adjustment type 'value', there are some potential ways in which this system can be extended:

- **One Product with more than one Offer**: Rather than simply creating a one-to-one relationship between Products and Offers, I went for keeping a many-to-many relationship between these two. This allows not only for having two products with the same offer (Buy1Get1Free should be recorded just once in the database, and linked to whatever products you want), but also the other way around: two offers that belong to the same product. Should one offer have priority over the other? Should they accumulate?

- **Collections of Products**: Products can belong to Sections, or Collections, or Specials. A straightforward extension would be to make the relation between Offer and Product polymorphic, so that an Offer could reference not just Products, but aggregations of product. An alternative implementation would be LineItems that point to more than one Product, but seems difficult to scale and do business intelligence with.
