require 'rails_helper'

RSpec.describe Point, type: :model do
  let!(:expiry_datetime) { Time.now + 1.year }
  let!(:user) { User.create(first_name: 'John', last_name: 'Doe', email: 'jdoe@example.com', birthday: Date.parse('11-11-1990')) }
  let!(:manager) { PointRewardManager.create(user: user) }
  let!(:order_transaction) { OrderTransaction.create(amount: 10000.09, user: user)}
  let!(:order_transaction_2) { OrderTransaction.create(amount: 20000.09, user: user)}
  let!(:local_point) {LocalPoint.create(order_transaction: order_transaction, point_reward_manager: manager) }
  let!(:international_point) {InternationalPoint.create(order_transaction: order_transaction_2, point_reward_manager: manager) }

  context "Attributes" do

    it "has valid attributes" do
      expect(local_point.quantity).to eq 1000
      expect(local_point.expired).to eq false
      expect(expiry_datetime - local_point.expire_at).to be <= 60000
      expect(international_point.quantity).to eq 4000
      expect(international_point.expired).to eq false
      expect(expiry_datetime - international_point.expire_at).to be <= 60000
    end
  end

  context "Associations" do
    it "has one order_transaction" do
      expect(local_point.order_transaction).to eq order_transaction
      expect(international_point.order_transaction).to eq order_transaction_2
    end
  end

end
