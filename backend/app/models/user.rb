class User < ApplicationRecord
  has_many :redemptions, dependent: :destroy
  has_many :rewards, through: :redemptions

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :points_balance,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
