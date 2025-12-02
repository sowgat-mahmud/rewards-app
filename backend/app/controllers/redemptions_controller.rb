class RedemptionsController < ApplicationController
  # POST /redemptions
  def create
    # In a real app we will use current_user; for this we are using user_id explicitly in the request body.
    user   = User.find(params.require(:user_id))
    reward = Reward.find(params.require(:reward_id))
    
    Rails.logger.info("DEBUG: calling RedemptionJob.perform_later with #{user.id}, #{reward.id}")


    RedemptionJob.perform_later(user.id, reward.id)

    render json: {
      status: "queued",
      user_id: user.id,
      reward_id: reward.id
    }, status: :accepted
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  end
end
