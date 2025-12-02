class Reward < ApplicationRecord
  has_many :redemptions, dependent: :restrict_with_error

  enum :category, { gift_card: 0, merchandise: 1, experience: 2 }

  validates :name, presence: true
  validates :cost_in_points,
            numericality: { only_integer: true, greater_than: 0 }
  validates :inventory,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :available, -> { where('inventory > 0') }
end
