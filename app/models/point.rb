class Point < ActiveRecord::Base
  belongs_to :order_transaction
  belongs_to :point_reward_manager

  def conversion_rate
    raise NotImplementedError
  end
end
