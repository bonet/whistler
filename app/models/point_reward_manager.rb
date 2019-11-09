class PointRewardManager < ActiveRecord::Base
  belongs_to :user
  has_many :points
  has_and_belongs_to_many :rewards

  validates :user, presence: true

  def issue_point(order_transaction:, type: 'local')
    return if order_transaction.blank? || !['local', 'international'].include?(type)
    klass = Object.const_get("#{type.capitalize}Point")
    point = klass.create(order_transaction: order_transaction, point_reward_manager: self)
  end

  def issue_reward
    calculate_reward_free_coffee
    calculate_reward_cash_rebate
  end

  private

  def calculate_reward_free_coffee
    if self.user.birthday.month == Time.now.month
      self.rewards << Reward.find_by(reward_type: 'free_coffee')
    end

    if self.points.where(expired: false, created_at:
      last_month_start..last_month_end).sum(:quantity) >= 100
      self.rewards << Reward.find_by(reward_type: 'free_coffee')
    end
  end

  def calculate_reward_cash_rebate
    if self.user.order_transactions.where("amount > ?", 100).where(
      created_at: last_month_start..last_month_end).count >= 10
      self.rewards << Reward.find_by(reward_type: 'cash_rebate')
    end
  end

  def last_month_start
    Time.now.last_month.beginning_of_month
  end

  def last_month_end
    Time.now.last_month.end_of_month
  end
end
