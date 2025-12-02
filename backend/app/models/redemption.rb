class Redemption < ApplicationRecord
  belongs_to :user
  belongs_to :reward

  enum :status, { pending: 0, completed: 1, failed: 2 }

  validates :points_cost,
            numericality: { only_integer: true, greater_than: 0 }
end
