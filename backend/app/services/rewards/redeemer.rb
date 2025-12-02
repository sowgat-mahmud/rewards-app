module Rewards
  class Redeemer
    class Error < StandardError; end
    class InsufficientPoints < Error; end
    class OutOfStock < Error; end

    def initialize(user:, reward:)
      @user = user
      @reward = reward
    end

    def call
      Redemption.transaction do
        # Lock both user and reward rows to avoid race conditions
        @user.lock!
        @reward.lock!

        raise OutOfStock, "Reward is out of stock" if @reward.inventory <= 0
        raise InsufficientPoints, "Not enough points" if @user.points_balance < @reward.cost_in_points

        @user.points_balance -= @reward.cost_in_points
        @reward.inventory -= 1

        @user.save!
        @reward.save!

        Redemption.create!(
          user: @user,
          reward: @reward,
          points_cost: @reward.cost_in_points,
          status: :completed
        )
      end
    end
  end
end
