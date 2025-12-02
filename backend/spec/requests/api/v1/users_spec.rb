require "rails_helper"

RSpec.describe "Api::V1::Users", type: :request do
  describe "GET /api/v1/users/:id" do
    it "returns the user with basic fields" do
      user = User.create!(
        name: "Alice",
        email: "alice@example.com",
        points_balance: 500
      )

      get "/api/v1/users/#{user.id}"

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      expect(body).to include(
        "id" => user.id,
        "name" => "Alice",
        "email" => "alice@example.com",
        "points_balance" => 500
      )
    end
  end

  describe "GET /api/v1/users/demo" do
    it "returns the demo user by email" do
      demo = User.create!(
        name: "Demo User",
        email: "demo@example.com",
        points_balance: 1000
      )

      get "/api/v1/users/demo"

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      expect(body["id"]).to eq(demo.id)
      expect(body["email"]).to eq("demo@example.com")
    end
  end
end
