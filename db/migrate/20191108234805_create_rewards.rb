class CreateRewards < ActiveRecord::Migration[5.0]
  def change
    create_table :rewards do |t|
      t.string :reward_type, unique: true, null: false
      t.string :name
    end
  end
end
