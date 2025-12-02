require "rails_helper"

RSpec.describe "Api::V1::Rewards", type: :request do
  describe "GET /api/v1/rewards" do
    it "returns rewards with availability flag" do
      Reward.create!(
        name: "Coffee Mug",
        cost_in_points: 200,
        inventory: 10,
        category: :merchandise
      )

      Reward.create!(
        name: "Sold Out Tee",
        cost_in_points: 300,
        inventory: 0,
        category: :merchandise
      )

      get "/api/v1/rewards"

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      expect(body.size).to eq(2)

      mug = body.find { |r| r["name"] == "Coffee Mug" }
      tee = body.find { |r| r["name"] == "Sold Out Tee" }

      expect(mug["available"]).to eq(true)
      expect(tee["available"]).to eq(false)
    end
  end
end
