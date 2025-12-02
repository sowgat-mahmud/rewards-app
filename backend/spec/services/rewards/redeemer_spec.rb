require "rails_helper"

RSpec.describe Rewards::Redeemer, type: :service do
  let(:user)   { User.create!(name: "Test User", email: "test@example.com", points_balance: starting_points) }
  let(:reward) { Reward.create!(name: "Gift Card", cost_in_points: 100, inventory: starting_inventory, category: :gift_card) }

  let(:service) { described_class.new(user: user, reward: reward) }

  context "when user has enough points and reward is in stock" do
    let(:starting_points)     { 200 }
    let(:starting_inventory)  { 5 }

    it "creates a completed redemption and updates balances" do
      redemption = service.call

      expect(redemption).to be_persisted
      expect(redemption).to be_completed
      expect(redemption.points_cost).to eq(100)

      expect(user.reload.points_balance).to eq(100)   # 200 - 100
      expect(reward.reload.inventory).to eq(4)        # 5 - 1
    end
  end

  context "when user does not have enough points" do
    let(:starting_points)     { 50 }
    let(:starting_inventory)  { 5 }

    it "raises InsufficientPoints and does not change balances" do
      expect {
        service.call
      }.to raise_error(Rewards::Redeemer::InsufficientPoints)

      expect(user.reload.points_balance).to eq(50)
      expect(reward.reload.inventory).to eq(5)
      expect(Redemption.count).to eq(0)
    end
  end

  context "when reward is out of stock" do
    let(:starting_points)     { 200 }
    let(:starting_inventory)  { 0 }

    it "raises OutOfStock and does not change balances" do
      expect {
        service.call
      }.to raise_error(Rewards::Redeemer::OutOfStock)

      expect(user.reload.points_balance).to eq(200)
      expect(reward.reload.inventory).to eq(0)
      expect(Redemption.count).to eq(0)
    end
  end
end
