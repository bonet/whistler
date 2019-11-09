class Reward < ActiveRecord::Base
  has_and_belongs_to_many :point_reward_managers
end
