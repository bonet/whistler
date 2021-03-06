require 'rails_helper'

RSpec.describe User, type: :model do
  let!(:user) { User.create(first_name: 'John', last_name: 'Doe', email: 'jdoe@example.com', birthday: Date.parse('11-11-1990')) }
  let!(:order_transaction) { OrderTransaction.create(amount: 10000.09, user: user)}

  context "Attributes" do

    it "has valid attributes" do
      expect(user.email).to eq 'jdoe@example.com'
      expect(user.birthday).to eq Date.parse('11-11-1990')
      expect(user.loyalty_tier).to eq 'standard'
    end
  end

  context "Associations" do
    it "has many order_transactions" do
      user.order_transactions.reload
      expect(user.order_transactions.count).to eq 1
      expect(user.order_transactions.first).to eq order_transaction
    end
  end

end
