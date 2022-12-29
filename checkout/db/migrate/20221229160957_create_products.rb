class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :code
      t.text :name
      t.decimal :price, precision: 2, scale: 9

      t.timestamps
    end
    add_index :products, :code, unique: true
  end
end
