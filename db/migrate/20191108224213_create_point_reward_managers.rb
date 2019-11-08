class CreatePointRewardManagers < ActiveRecord::Migration[5.0]
  def change
    create_table :point_reward_managers do |t|
      t.references :user
    end

    add_reference :points, :point_reward_manager
  end
end
