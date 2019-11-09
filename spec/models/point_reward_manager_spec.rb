require 'rails_helper'
require "rake"
Rails.application.load_tasks

RSpec.describe PointRewardManager, type: :model do
  before(:all) do
    @user = User.create(first_name: 'John', last_name: 'Doe', email: 'jdoe@example.com', birthday: Date.parse('11-11-1990'))
    @manager = PointRewardManager.create(user: @user)
    @reward = Reward.create(reward_type: 'free_coffee')
    @reward_2 = Reward.create(reward_type: 'cash_rebate')

    Timecop.freeze(Time.now.last_month) do
      @order = OrderTransaction.create(amount: 10000.09, user: @user)
      @order_2 = OrderTransaction.create(amount: 20000.09, user: @user)

      (1..8).each do |i|
        OrderTransaction.create(amount: rand(100..10000), user: @user)
      end

      @manager.issue_point(order_transaction: @order, type: 'local')
      @manager.issue_point(order_transaction: @order_2, type: 'international')
    end
  end

  context "Attributes" do

    it "has valid attributes" do
    end
  end

  context "Associations" do
    it "has many-to-many relationship with Reward" do
    end

    it "has many Point" do

    end
  end

  context "issue point" do
    it "can issue point" do
      local_point = @manager.points.first
      international_point = @manager.points.last
      expect(local_point.quantity).to eq 1000
      expect(international_point.quantity).to eq 4000
    end

    it "can issue reward" do
      @manager.issue_reward
      expect(@manager.rewards.where(reward_type: 'free_coffee').count).to eq 2
      expect(@manager.rewards.where(reward_type: 'cash_rebate').count).to eq 1
    end
  end
end
