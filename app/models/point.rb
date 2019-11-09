class Point < ActiveRecord::Base
  belongs_to :order_transaction
  belongs_to :point_reward_manager

  validates :order_transaction, :point_reward_manager, presence: true

  before_create :set_expire_at
  before_create :set_quantity

  def set_expire_at
    self.expire_at = Time.now + 1.year
  end

  def set_quantity
    point_units = (self.order_transaction.amount / self.class::CONVERSION_DOLLAR).floor
    self.quantity = point_units * self.class::CONVERSION_POINT
  end
end
