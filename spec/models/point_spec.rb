require 'rails_helper'

RSpec.describe Point, type: :model do
  let!(:expiry_datetime) { Time.now + 1.year }
  let!(:user) { User.create(first_name: 'John', last_name: 'Doe', email: 'jdoe@example.com') }
  let!(:manager) { PointRewardManager.create(user: user) }
  let!(:order_transaction) { OrderTransaction.create(amount: 10000.09, user: user)}
  let!(:order_transaction_2) { OrderTransaction.create(amount: 20000.09, user: user)}
  let!(:local_point) {LocalPoint.create(order_transaction: order_transaction, quantity: 10, expired_at: expiry_datetime, point_reward_manager: manager) }
  let!(:international_point) {InternationalPoint.create(order_transaction: order_transaction_2, quantity: 20, expired_at: expiry_datetime, point_reward_manager: manager) }

  context "Attributes" do

    it "has valid attributes" do
      expect(local_point.quantity).to eq 10
      expect(local_point.expired).to eq false
      expect(local_point.expired_at).to eq expiry_datetime
      expect(international_point.quantity).to eq 20
      expect(international_point.expired).to eq false
      expect(international_point.expired_at).to eq expiry_datetime
    end
  end

  context "Associations" do
    it "has one order_transaction" do
      expect(local_point.order_transaction).to eq order_transaction
      expect(international_point.order_transaction).to eq order_transaction_2
    end
  end

end
