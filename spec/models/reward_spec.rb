require 'rails_helper'

RSpec.describe Reward, type: :model do
  before(:all) do
    @expiry_datetime = Time.now + 1.year
    @user = User.create(first_name: 'John', last_name: 'Doe', email: 'jdoe@example.com', birthday: Date.parse('11-11-1990'))
    @manager = PointRewardManagerService.new(user: @user)
    @reward = Reward.create(reward_type: 'free_coffee')
    @reward_2 = Reward.create(reward_type: 'cash_rebate')
    @user.rewards << @reward
    @user.rewards << @reward_2
  end

  context "Attributes" do

    it "has valid attributes" do
      expect(@reward.reward_type).to eq 'free_coffee'
      expect(@reward_2.reward_type).to eq 'cash_rebate'
    end
  end

  context "Associations" do
    it "has many-to-many relationship with User" do
      expect(@reward.users.count).to eq 1
      expect(@reward_2.users.count).to eq 1
      expect(@user.rewards).to eq [@reward, @reward_2]
    end
  end
end
