module Api
  module V1
    class RewardsController < ApplicationController
      # GET /api/v1/rewards
      def index
        rewards = Reward.order(:id)

        render json: rewards.map { |reward|
          {
            id: reward.id,
            name: reward.name,
            cost_in_points: reward.cost_in_points,
            inventory: reward.inventory,
            category: reward.category, # enum -> string ("gift_card", etc.)
            available: reward.inventory.positive?
          }
        }
      end
    end
  end
end
