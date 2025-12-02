module Api
  module V1
    class RedemptionsController < ApplicationController
      before_action :set_user, only: :index

      # GET /api/v1/users/:user_id/redemptions
      def index
        redemptions = @user.redemptions.includes(:reward).order(created_at: :desc)

        render json: redemptions.map { |r|
          {
            id: r.id,
            status: r.status,           # enum -> string
            points_cost: r.points_cost,
            reward: {
              id: r.reward.id,
              name: r.reward.name
            },
            created_at: r.created_at
          }
        }
      end

      # POST /api/v1/redemptions
      # This is the synchronous version using Rewards::Redeemer directly.
      def create
        user   = User.find(redemption_params[:user_id])
        reward = Reward.find(redemption_params[:reward_id])

        redemption = Rewards::Redeemer.new(user: user, reward: reward).call

        render json: {
          redemption: {
            id: redemption.id,
            status: redemption.status,
            points_cost: redemption.points_cost,
            reward: {
              id: redemption.reward.id,
              name: redemption.reward.name
            }
          },
          user: {
            id: user.id,
            points_balance: user.points_balance
          }
        }, status: :created
      rescue Rewards::Redeemer::InsufficientPoints => e
        render json: { error: e.message }, status: :unprocessable_entity
      rescue Rewards::Redeemer::OutOfStock => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      private

      def set_user
        @user = User.find(params[:user_id])
      end

      # Strong params for POST /api/v1/redemptions
      def redemption_params
        params.require(:redemption).permit(:user_id, :reward_id)
      end
    end
  end
end
