class User < ActiveRecord::Base
  enum loyalty_tier: { standard: 0, gold: 1, platinum: 2 }

  has_many :order_transactions
  has_many :points
  has_many :user_rewards
  has_many :rewards, through: :user_rewards

  validates :birthday, presence: true
end
