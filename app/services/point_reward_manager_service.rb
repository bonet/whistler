class PointRewardManagerService
  attr_reader :user

  def initialize(user:)
    @user = user
  end

  def issue_point(order_transaction:, type:)
    return if order_transaction.blank? || !['local', 'international'].include?(type)

    calculate_quarterly_bonus_point
    create_point(order_transaction, type)
  end

  def issue_reward
    calculate_reward_free_coffee
    calculate_reward_cash_rebate
    calculate_free_movie_tickets
  end

  def expire_points
    user.points.where("expire_at < ?", Time.now).each do |point|
      point.expire!
    end
  end

  def calculate_quarterly_bonus_point
    current_year = Time.now.year
    current_quarter = get_quarter(Time.now.month)

    label = "bonus_#{current_quarter}_#{current_year}"
    month_range = get_month_range(current_quarter)
    month_start = month_range.first
    month_end = month_range.last

    if user.points.where(label: label).count == 0 && user.order_transactions.where(
      created_at: DateTime.parse("1-#{month_start}-#{current_year}").beginning_of_month..
      DateTime.parse("1-#{month_end}-#{current_year}").end_of_month).sum(:amount) > 2000
      order = user.order_transactions.create(amount: 0) # create fake order
      user.points.create(order_transaction: order, quantity: 100, label: label, type: 'LocalPoint')
      update_user_loyalty_tier
    end
  end

  def get_month_range(quarter)
    quarter_months = {
      1 => (1..3),
      2 => (4..6),
      3 => (7..9),
      4 => (10..12)
    }

    quarter_months[quarter]
  end

  def get_quarter(month)
    quarter_months = {
      1 => (1..3),
      2 => (4..6),
      3 => (7..9),
      4 => (10..12)
    }

    q = nil
    quarter_months.each do |quarter, month_range|
      if month_range.include?(month)
        q = quarter
        break
      end
    end

    q
  end

  private

  def create_point(order_transaction, type)
    klass = Object.const_get("#{type.capitalize}Point")
    user.points.create(order_transaction: order_transaction, type: klass)
    update_user_loyalty_tier
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

  def calculate_reward_free_coffee
    if user.birthday.month == Time.now.month
      user.rewards << Reward.find_by(reward_type: 'free_coffee')
    end

    if user.points.where(expired: false, created_at:
      last_month_start..last_month_end).sum(:quantity) >= 100
      user.rewards << Reward.find_by(reward_type: 'free_coffee')
    end
  end

  def calculate_reward_cash_rebate
    if user.order_transactions.where("amount > ?", 100).where(
      created_at: last_month_start..last_month_end).count >= 10
      user.rewards << Reward.find_by(reward_type: 'cash_rebate')
    end
  end

  def calculate_free_movie_tickets
    if user.rewards.where(reward_type: 'free_movie_tickets').count == 0
      first_transaction = user.order_transactions.order("id ASC").first
      first_transaction_date = first_transaction.created_at
      if user.order_transactions.where(created_at:
        first_transaction_date..(first_transaction_date+60.days)).sum(:amount) > 1000
        user.rewards << Reward.find_by(reward_type: 'free_movie_tickets')
      end
    end
  end

  def last_month_start
    Time.now.last_month.beginning_of_month
  end

  def last_month_end
    Time.now.last_month.end_of_month
  end
end

