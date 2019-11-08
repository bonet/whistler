require 'rails_helper'

RSpec.describe User, type: :model do
  let!(:user) { User.create(first_name: 'John', last_name: 'Doe', email: 'jdoe@example.com') }
  let!(:transaction) { Transaction.create(amount: 10000.09, user: user)}

  context "Attributes" do

    it "has valid attributes" do
      expect(user.email).to eq 'jdoe@example.com'
      expect(user.loyalty_tier).to eq 'standard'
    end
  end

  context "Associations" do
    it "has many transactions" do
      expect(user.transactions.count).to eq 1
      expect(user.transactions.first).to eq transaction
    end
  end

end
