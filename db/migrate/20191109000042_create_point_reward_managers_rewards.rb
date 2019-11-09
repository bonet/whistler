class CreatePointRewardManagersRewards < ActiveRecord::Migration[5.0]
  def change
    create_table :point_reward_managers_rewards do |t|
      t.belongs_to :reward, index: { name: 'idx_managers_rewards' }
      t.belongs_to :point_reward_manager, index: { name: 'idx_managers_point_reward_managers' }
    end
  end
end
