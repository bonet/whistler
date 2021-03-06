class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.date :birthday
      t.integer :loyalty_tier, default: 0, null: false
      t.timestamps
    end
  end
end
