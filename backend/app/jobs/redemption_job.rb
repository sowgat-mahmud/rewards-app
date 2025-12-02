class RedemptionJob < ApplicationJob
  queue_as :default

  def perform(user_id, reward_id)
    user   = User.find(user_id)
    reward = Reward.find(reward_id)

    Rewards::Redeemer.new(user: user, reward: reward).call
  rescue Rewards::Redeemer::Error => e
    Rails.logger.error("Redemption failed: #{e.message}")
  end
end
