class CreatePoints < ActiveRecord::Migration[5.0]
  def change
    create_table :points do |t|
      t.string :type, index: true
      t.references :order_transaction
      t.integer :quantity, default: 0
      t.integer :quantity_used, default: 0
      t.boolean :expired, default: false
      t.datetime :expire_at

      t.timestamps
    end
  end
end
