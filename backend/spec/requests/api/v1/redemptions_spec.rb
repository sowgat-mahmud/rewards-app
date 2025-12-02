require "rails_helper"

RSpec.describe "Api::V1::Redemptions", type: :request do
  describe "POST /api/v1/redemptions" do
    it "creates a redemption and returns updated user+redemption payload" do
      user = User.create!(
        name: "Alice",
        email: "alice@example.com",
        points_balance: 500
      )

      reward = Reward.create!(
        name: "Gift Card",
        cost_in_points: 200,
        inventory: 3,
        category: :gift_card
      )

      expect {
        post "/api/v1/redemptions",
             params: {
               redemption: {
                 user_id: user.id,
                 reward_id: reward.id
               }
             }
      }.to change(Redemption, :count).by(1)

      expect(response).to have_http_status(:created)

      body = JSON.parse(response.body)

      # user balance updated
      expect(body.dig("user", "points_balance")).to eq(300)

      # redemption JSON
      redemption_json = body["redemption"]
      expect(redemption_json["status"]).to eq("completed")
      expect(redemption_json.dig("reward", "id")).to eq(reward.id)

      user.reload
      reward.reload
      expect(user.points_balance).to eq(300)
      expect(reward.inventory).to eq(2)
    end

    it "returns 422 when user has insufficient points" do
      user = User.create!(
        name: "Bob",
        email: "bob@example.com",
        points_balance: 50
      )

      reward = Reward.create!(
        name: "Expensive Reward",
        cost_in_points: 100,
        inventory: 1,
        category: :gift_card
      )

      expect {
        post "/api/v1/redemptions",
             params: {
               redemption: {
                 user_id: user.id,
                 reward_id: reward.id
               }
             }
      }.not_to change(Redemption, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body["error"]).to match(/Not enough points/i)
    end
  end

  describe "GET /api/v1/users/:user_id/redemptions" do
    it "returns the user's redemption history" do
      user = User.create!(
        name: "History User",
        email: "history@example.com",
        points_balance: 500
      )

      reward = Reward.create!(
        name: "Mug",
        cost_in_points: 200,
        inventory: 10,
        category: :merchandise
      )

      redemption = Redemption.create!(
        user: user,
        reward: reward,
        points_cost: reward.cost_in_points,
        status: :completed
      )

      get "/api/v1/users/#{user.id}/redemptions"

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      expect(body.length).to eq(1)

      rec = body.first
      expect(rec["id"]).to eq(redemption.id)
      expect(rec["points_cost"]).to eq(200)
      expect(rec.dig("reward", "name")).to eq("Mug")
    end
  end
end
