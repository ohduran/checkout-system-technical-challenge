class CreateOffers < ActiveRecord::Migration[7.0]
  def change
    create_table :offers do |t|
      t.string :offer_type
      t.string :adjustment_type
      t.integer :quantity_to_buy
      t.integer :quantity_to_get
      t.decimal :amount, precision: 2, scale: 9

      t.timestamps
    end
    add_index :offers, :offer_type
  end
end
