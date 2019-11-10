class CreatePoints < ActiveRecord::Migration[5.0]
  def change
    create_table :points do |t|
      t.string :type, index: true
      t.belongs_to :order_transaction
      t.belongs_to :user
      t.integer :quantity, default: 0
      t.integer :quantity_used, default: 0
      t.boolean :expired, default: false
      t.string :label, index: true
      t.datetime :expire_at

      t.timestamps
    end
  end
end
