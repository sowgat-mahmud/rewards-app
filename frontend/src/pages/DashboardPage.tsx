import React, { useEffect, useState } from "react";
import { fetchUser, type User } from "../api/users";
import { fetchRewards, type Reward } from "../api/rewards";
import {
  fetchUserRedemptions,
  createRedemption,
  type Redemption,
} from "../api/redemptions";

import ErrorBanner from "../components/ErrorBanner";
import BalancePanel from "../components/BalancePanel";
import RewardsList from "../components/RewardsList";
import RedemptionHistory from "../components/RedemptionHistory";

const DEMO_USER_ID = 42; // seeded demo user gets ID 42

const DashboardPage: React.FC = () => {
  const [user, setUser] = useState<User | null>(null);
  const [rewards, setRewards] = useState<Reward[]>([]);
  const [redemptions, setRedemptions] = useState<Redemption[]>([]);
  const [loading, setLoading] = useState(true);
  const [loadingRewards, setLoadingRewards] = useState(true);
  const [loadingHistory, setLoadingHistory] = useState(true);
  const [redeemingId, setRedeemingId] = useState<number | null>(null);
  const [error, setError] = useState<string | null>(null);

  // Initial load
  useEffect(() => {
    async function load() {
      setLoading(true);
      setError(null);

      try {
        const [userData, rewardsData, redemptionsData] = await Promise.all([
          fetchUser(DEMO_USER_ID),
          fetchRewards(),
          fetchUserRedemptions(DEMO_USER_ID),
        ]);

        setUser(userData);
        setRewards(rewardsData);
        setRedemptions(redemptionsData);
      } catch (err) {
        setError((err as Error).message);
      } finally {
        setLoading(false);
        setLoadingRewards(false);
        setLoadingHistory(false);
      }
    }

    load();
  }, []);

  async function handleRedeem(rewardId: number) {
    if (!user) return;

    setRedeemingId(rewardId);
    setError(null);

    try {
      const result = await createRedemption(user.id, rewardId);

      // Update user balance
      setUser((prev) =>
        prev ? { ...prev, points_balance: result.user.points_balance } : prev
      );

      // Add new redemption at top
      setRedemptions((prev) => [result.redemption, ...prev]);

      // Update reward inventory/availability locally
      setRewards((prev) =>
        prev.map((r) =>
          r.id === rewardId
            ? {
                ...r,
                inventory: r.inventory - 1,
                available: r.inventory - 1 > 0,
              }
            : r
        )
      );
    } catch (err) {
      setError((err as Error).message);
    } finally {
      setRedeemingId(null);
    }
  }

  return (
    <div
      style={{
        maxWidth: 900,
        margin: "0 auto",
        padding: 24,
        fontFamily: "system-ui, -apple-system, BlinkMacSystemFont, sans-serif",
      }}
    >
      <h1 style={{ marginTop: 0, marginBottom: 16 }}>Rewards Dashboard</h1>

      <ErrorBanner message={error} />

      <BalancePanel user={user} loading={loading} />

      <div
        style={{
          display: "grid",
          gridTemplateColumns: "2fr 1.5fr",
          gap: 16,
          alignItems: "flex-start",
        }}
      >
        <RewardsList
          user={user}
          rewards={rewards}
          loading={loadingRewards}
          redeemingId={redeemingId}
          onRedeem={handleRedeem}
        />
        <RedemptionHistory
          redemptions={redemptions}
          loading={loadingHistory}
        />
      </div>
    </div>
  );
};

export default DashboardPage;
