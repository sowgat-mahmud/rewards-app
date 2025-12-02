require "rails_helper"

RSpec.describe RedemptionJob, type: :job do
  let(:user) do
    User.create!(
      name: "Test User",
      email: "job-test@example.com",
      points_balance: 200
    )
  end

  let(:reward) do
    Reward.create!(
      name: "Gift Card",
      cost_in_points: 100,
      inventory: 5,
      category: :gift_card
    )
  end

  it "delegates to Rewards::Redeemer with the correct user and reward" do
    redeemer_double = instance_double(Rewards::Redeemer)

    expect(Rewards::Redeemer)
      .to receive(:new)
      .with(user: user, reward: reward)
      .and_return(redeemer_double)

    expect(redeemer_double).to receive(:call)

    described_class.perform_now(user.id, reward.id)
  end
end
