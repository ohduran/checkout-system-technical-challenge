class CreateLineItems < ActiveRecord::Migration[7.0]
  def change
    create_table :line_items do |t|
      t.references :basket
      t.integer :quantity
      t.references :product

      t.timestamps
    end
    add_index :line_items, :basket
  end
end
