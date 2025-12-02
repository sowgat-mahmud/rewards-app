require "rails_helper"

RSpec.describe "Redemptions", type: :request do
  let(:user) do
    User.create!(
      name: "API User",
      email: "api-user@example.com",
      points_balance: 200
    )
  end

  let(:reward) do
    Reward.create!(
      name: "API Gift Card",
      cost_in_points: 100,
      inventory: 5,
      category: :gift_card
    )
  end

  it "returns 202 and a queued status" do
    post "/redemptions", params: { user_id: user.id, reward_id: reward.id }

    expect(response).to have_http_status(:accepted)

    body = JSON.parse(response.body)
    expect(body["status"]).to eq("queued")
    expect(body["user_id"]).to eq(user.id)
    expect(body["reward_id"]).to eq(reward.id)
  end
end
