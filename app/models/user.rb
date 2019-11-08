class User < ActiveRecord::Base
  enum loyalty_tier: { standard: 0, gold: 1, platinum: 2 }

  has_many :transactions
end
