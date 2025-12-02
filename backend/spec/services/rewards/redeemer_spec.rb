require "rails_helper"

RSpec.describe Rewards::Redeemer, type: :service do
  let(:user) do
    User.create!(
      name: "Test User",
      email: "test@example.com",
      points_balance: starting_points
    )
  end

  let(:reward) do
    Reward.create!(
      name: "Gift Card",
      cost_in_points: 100,
      inventory: starting_inventory,
      category: :gift_card
    )
  end

  let(:service) { described_class.new(user: user, reward: reward) }

  context "when user has enough points and reward is in stock" do
    let(:starting_points)    { 200 }
    let(:starting_inventory) { 5 }

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
    let(:starting_points)    { 50 }
    let(:starting_inventory) { 5 }

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
    let(:starting_points)    { 200 }
    let(:starting_inventory) { 0 }

    it "raises OutOfStock and does not change balances" do
      expect {
        service.call
      }.to raise_error(Rewards::Redeemer::OutOfStock)

      expect(user.reload.points_balance).to eq(200)
      expect(reward.reload.inventory).to eq(0)
      expect(Redemption.count).to eq(0)
    end
  end

  describe "concurrency / locking" do
    it "prevents double-spending when two redemptions run concurrently" do
      concurrent_user = User.create!(
        name: "Concurrent User",
        email: "concurrent@example.com",
        points_balance: 1000
      )

      limited_reward = Reward.create!(
        name: "Limited Edition",
        cost_in_points: 400,
        inventory: 1,
        category: :merchandise
      )

      errors = []

      threads = 2.times.map do
        Thread.new do
          begin
            described_class.new(user: concurrent_user, reward: limited_reward).call
          rescue described_class::Error => e
            errors << e
          end
        end
      end

      threads.each(&:join)

      # Only one successful redemption
      expect(Redemption.where(user: concurrent_user, reward: limited_reward).count).to eq(1)

      concurrent_user.reload
      limited_reward.reload

      expect(concurrent_user.points_balance).to eq(600) # 1000 - 400
      expect(limited_reward.inventory).to eq(0)
      expect(errors.size).to eq(1)                      # one failed because of locking/stock
    end
  end
end
