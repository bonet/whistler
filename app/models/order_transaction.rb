class OrderTransaction < ActiveRecord::Base
  belongs_to :user
  has_one :point
end
