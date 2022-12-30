# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 20_221_230_153_003) do
  create_table 'baskets', force: :cascade do |t|
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'line_items', force: :cascade do |t|
    t.integer 'basket_id'
    t.integer 'quantity'
    t.integer 'product_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index '"basket"', name: 'index_line_items_on_basket'
    t.index ['basket_id'], name: 'index_line_items_on_basket_id'
    t.index ['product_id'], name: 'index_line_items_on_product_id'
  end

  create_table 'offers', force: :cascade do |t|
    t.string 'offer_type'
    t.string 'adjustment_type'
    t.integer 'quantity_to_buy'
    t.integer 'quantity_to_get'
    t.decimal 'amount', precision: 2, scale: 9
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['offer_type'], name: 'index_offers_on_offer_type'
  end

  create_table 'offers_products', id: false, force: :cascade do |t|
    t.integer 'offer_id', null: false
    t.integer 'product_id', null: false
  end

  create_table 'products', force: :cascade do |t|
    t.string 'code'
    t.text 'name'
    t.decimal 'price', precision: 2, scale: 9
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.integer 'offer_id'
    t.index ['code'], name: 'index_products_on_code', unique: true
    t.index ['offer_id'], name: 'index_products_on_offer_id'
  end

  add_foreign_key 'products', 'offers'
end
