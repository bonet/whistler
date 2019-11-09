class PointRewardManager < ActiveRecord::Base
  belongs_to :user
  has_many :points
  has_and_belongs_to_many :rewards

  validates :user, presence: true

  def issue_point(order_transaction:, type:)
    return if order_transaction.blank? || !['local', 'international'].include?(type)

    create_point(order_transaction, type)
    update_user_loyalty_tier
  end

  def issue_reward
    calculate_reward_free_coffee
    calculate_reward_cash_rebate
  end

  private

  def create_point(order_transaction, type)
    klass = Object.const_get("#{type.capitalize}Point")
    self.points.create(order_transaction: order_transaction, type: klass)
  end

  def update_user_loyalty_tier
    total_points = self.points.where(expired: false).sum(:quantity)

    if total_points < 1000
      user.loyalty_tier = :standard
    elsif total_points >=1000 && total_points < 5000
      user.loyalty_tier = :gold
    elsif total_points >= 5000
      user.loyalty_tier = :platinum
    end

    user.save

    calculate_reward_after_loyalty_tier_changed
  end

  def calculate_reward_after_loyalty_tier_changed
    previous_loyalty_tier = user.previous_changes['loyalty_tier']&.[](0)
    current_loyalty_tier = user.loyalty_tier

    if previous_loyalty_tier=='standard' && ['gold'].include?(current_loyalty_tier)
      (1..4).each do
        self.rewards << Reward.find_by(reward_type: 'airport_lounge_access')
      end
    end
  end

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
