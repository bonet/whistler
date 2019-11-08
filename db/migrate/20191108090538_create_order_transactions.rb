class CreateOrderTransactions < ActiveRecord::Migration[5.0]
  def change
    create_table :order_transactions do |t|
      t.decimal :amount, :precision => 8, :scale => 2
      t.references :user

      t.timestamps
    end
  end
end
