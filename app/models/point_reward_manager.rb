class PointRewardManager < ActiveRecord::Base
  belongs_to :user
  has_many :points

  def conversion_rate
    raise NotImplementedError
  end
end
