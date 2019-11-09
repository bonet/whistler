require 'rails_helper'

RSpec.describe PointRewardManagerService, type: :service do
  before(:all) do
    @user = User.create(first_name: 'John', last_name: 'Doe', email: 'jdoe@example.com', birthday: Date.parse('11-11-1990'))
    @manager = PointRewardManagerService.new(user: @user)

    @reward = Reward.create(reward_type: 'free_coffee')
    @reward_2 = Reward.create(reward_type: 'cash_rebate')
    @reward_3 = Reward.create(reward_type: 'airport_lounge_access')

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

      Timecop.freeze(Time.now.last_month) do
        @manager.issue_point(order_transaction: @order, type: 'local')
      end

      local_point = @user.points.where(type: 'LocalPoint').first
      expect(local_point.quantity).to eq 1000
      expect(@user.rewards.where(reward_type: 'airport_lounge_access').count).to eq 4
      expect(@user.loyalty_tier).to eq 'gold'

      Timecop.freeze(Time.now.last_month) do
        @manager.issue_point(order_transaction: @order_2, type: 'international')
      end

      international_point = @user.points.where(type: 'InternationalPoint').last
      expect(international_point.quantity).to eq 4000
      expect(@user.rewards.where(reward_type: 'airport_lounge_access').count).to eq 4
      expect(@user.loyalty_tier).to eq 'platinum'
    end

    it "can issue reward" do
      @user.reload
      Timecop.freeze(Time.now.last_month) do
        @manager.issue_point(order_transaction: @order, type: 'local')
      end

      @manager.issue_reward
      @user.rewards.reload

      expect(@user.rewards.where(reward_type: 'free_coffee').count).to eq 2
      expect(@user.rewards.where(reward_type: 'cash_rebate').count).to eq 1
      expect(@user.rewards.where(reward_type: 'airport_lounge_access').count).to eq 4
    end
  end
end
