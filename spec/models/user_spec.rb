require 'rails_helper'

RSpec.describe User, type: :model do
  let!(:user) { User.create(first_name: 'John', last_name: 'Doe', email: 'jdoe@example.com') }
  let!(:order_transaction) { OrderTransaction.create(amount: 10000.09, user: user)}
  let!(:manager) {PointRewardManager.create(user: user)}

  context "Attributes" do

    it "has valid attributes" do
      expect(user.email).to eq 'jdoe@example.com'
      expect(user.loyalty_tier).to eq 'standard'
    end
  end

  context "Associations" do
    it "has many order_transactions" do
      expect(user.order_transactions.count).to eq 1
      expect(user.order_transactions.first).to eq order_transaction
    end

    it "has one PointRewardManager" do
      expect(user.point_reward_manager).to eq manager
    end
  end

end
