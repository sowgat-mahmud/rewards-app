import type { Reward } from "../api/rewards";
import type { User } from "../api/users";

interface RewardsListProps {
  user: User | null;
  rewards: Reward[];
  loading: boolean;
  redeemingId: number | null;
  onRedeem: (rewardId: number) => void;
}

const RewardsList: React.FC<RewardsListProps> = ({
  user,
  rewards,
  loading,
  redeemingId,
  onRedeem,
}) => {
  return (
    <div
      style={{
        padding: 16,
        borderRadius: 8,
        border: "1px solid #e5e7eb",
        marginBottom: 16,
      }}
    >
      <h2 style={{ marginTop: 0 }}>Available Rewards</h2>

      {loading && <p>Loading rewards...</p>}

      {!loading && rewards.length === 0 && <p>No rewards available.</p>}

      {!loading && rewards.length > 0 && (
        <ul style={{ listStyle: "none", padding: 0, margin: 0 }}>
          {rewards.map((reward) => {
            const canAfford =
              !!user && user.points_balance >= reward.cost_in_points;
            const isOutOfStock = !reward.available;
            const isRedeeming = redeemingId === reward.id;

            let label = "Redeem";
            if (isOutOfStock) {
              label = "Out of stock";
            } else if (!canAfford) {
              label = "Not enough points";
            }

            const disabled = isOutOfStock || !canAfford || isRedeeming;

            return (
              <li
                key={reward.id}
                style={{
                  display: "flex",
                  justifyContent: "space-between",
                  alignItems: "center",
                  padding: "8px 0",
                  borderBottom: "1px solid #e5e7eb",
                }}
              >
                <div>
                  <div style={{ fontWeight: 500 }}>{reward.name}</div>
                  <div style={{ fontSize: 12, color: "#6b7280" }}>
                    {reward.cost_in_points} pts • {reward.category} •{" "}
                    {reward.inventory} in stock
                  </div>
                </div>

                <button
                  disabled={disabled}
                  onClick={() => onRedeem(reward.id)}
                  style={{
                    padding: "6px 12px",
                    borderRadius: 6,
                    border: "none",
                    cursor: disabled ? "not-allowed" : "pointer",
                    backgroundColor: disabled ? "#e5e7eb" : "#2563eb",
                    color: disabled ? "#6b7280" : "#ffffff",
                    minWidth: 120,
                  }}
                >
                  {isRedeeming ? "Redeeming..." : label}
                </button>
              </li>
            );
          })}
        </ul>
      )}
    </div>
  );
};

export default RewardsList;
