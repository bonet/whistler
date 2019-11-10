require 'rails_helper'

RSpec.describe PointRewardManagerService, type: :service do
  before(:all) do
    @user = User.create(first_name: 'John', last_name: 'Doe', email: 'jdoe@example.com', birthday: Date.parse('11-11-1990'))
    @manager = PointRewardManagerService.new(user: @user)

    @reward = Reward.create(reward_type: 'free_coffee')
    @reward_2 = Reward.create(reward_type: 'cash_rebate')
    @reward_3 = Reward.create(reward_type: 'airport_lounge_access')
    @reward_4 = Reward.create(reward_type: 'free_movie_tickets')

    Timecop.freeze(Time.now.last_month) do
      @order = OrderTransaction.create(amount: 10000.09, user: @user)
      @order_2 = OrderTransaction.create(amount: 20000.09, user: @user)

      (1..8).each do |i|
        OrderTransaction.create(amount: rand(100..10000), user: @user)
      end
    end
  end

  context "issue point" do
    it "can issue point" do
      @user.reload
      expect(@user.loyalty_tier).to eq 'standard' # Loyalty tiers - Level 1 - 1

      Timecop.freeze(Time.now.last_month) do
        @manager.issue_point(order_transaction: @order, type: 'local')
      end

      local_point = @user.points.where(type: 'LocalPoint', label: nil).first
      expect(local_point.quantity).to eq 1000 # Points - Level 1 - 1

      expect(@user.rewards.where(reward_type: 'airport_lounge_access').count).to eq 4 # Loyalty tiers - Level 2 - 3
      expect(@user.loyalty_tier).to eq 'gold' # Loyalty tiers - Level 1 - 2

      Timecop.freeze(Time.now.last_month) do
        @manager.issue_point(order_transaction: @order_2, type: 'international')
      end

      international_point = @user.points.where(type: 'InternationalPoint').last
      expect(international_point.quantity).to eq 4000 # Points - Level 2 - 1
      expect(@user.rewards.where(reward_type: 'airport_lounge_access').count).to eq 4
      expect(@user.loyalty_tier).to eq 'platinum' # Loyalty tiers - Level 1 - 3
    end

    it "can issue reward" do
      @user.reload
      Timecop.freeze(Time.now.last_month) do
        @manager.issue_point(order_transaction: @order, type: 'local')
      end

      @manager.issue_reward
      @user.rewards.reload

      expect(@user.rewards.where(reward_type: 'free_coffee').count).to eq 2 # Issuing rewards - Level 1 - 1 & Level 2 - 1
      expect(@user.rewards.where(reward_type: 'cash_rebate').count).to eq 1 # Issuing rewards - Level 2 - 2
      expect(@user.rewards.where(reward_type: 'airport_lounge_access').count).to eq 4
      expect(@user.rewards.where(reward_type: 'free_movie_tickets').count).to eq 1 # Issuing rewards - Level 2 - 3

      @manager.expire_points
      expect(@user.points.where(expired: true).count). to eq 0

      Timecop.freeze(Time.now.next_year) do
        @manager.expire_points
      end
      expect(@user.points.where(expired: true).count). to be > 0 # Loyalty tiers - Level 2 - 1

      @manager.calculate_quarterly_bonus_point
      current_quarter = @manager.get_quarter(Time.now.month)
      current_year = Time.now.year
      label = "bonus_#{current_quarter}_#{current_year}"
      expect(@user.points.where(label: label).count).to eq 1 # Loyalty tiers - Level 2 - 4
    end
  end
end
