class PointRewardManagerService
  attr_reader :user

  def initialize(user:)
    @user = user
  end

  def issue_point(order_transaction:, type:)
    return if order_transaction.blank? || !['local', 'international'].include?(type)

    create_point(order_transaction, type)
    update_user_loyalty_tier
  end

  def issue_reward
    monthly_calculate_reward_free_coffee
    monthly_calculate_reward_cash_rebate
  end

  def expire_points
    user.points.where("expire_at < ?", Time.now).destroy_all
  end

  private

  def create_point(order_transaction, type)
    klass = Object.const_get("#{type.capitalize}Point")
    user.points.create(order_transaction: order_transaction, type: klass)
  end

  def update_user_loyalty_tier
    total_points = user.points.where(expired: false).sum(:quantity)

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
        user.rewards << Reward.find_by(reward_type: 'airport_lounge_access')
      end
    end
  end

  def monthly_calculate_reward_free_coffee
    if user.birthday.month == Time.now.month
      user.rewards << Reward.find_by(reward_type: 'free_coffee')
    end

    if user.points.where(expired: false, created_at:
      last_month_start..last_month_end).sum(:quantity) >= 100
      user.rewards << Reward.find_by(reward_type: 'free_coffee')
    end
  end

  def monthly_calculate_reward_cash_rebate
    if user.order_transactions.where("amount > ?", 100).where(
      created_at: last_month_start..last_month_end).count >= 10
      user.rewards << Reward.find_by(reward_type: 'cash_rebate')
    end
  end

  def last_month_start
    Time.now.last_month.beginning_of_month
  end

  def last_month_end
    Time.now.last_month.end_of_month
  end
end

