import React from "react";
import type { Redemption } from "../api/redemptions";

interface RedemptionHistoryProps {
  redemptions: Redemption[];
  loading: boolean;
}

const RedemptionHistory: React.FC<RedemptionHistoryProps> = ({
  redemptions,
  loading,
}) => {
  return (
    <div style={{ padding: 16, borderRadius: 8, border: "1px solid #e5e7eb" }}>
      <h2 style={{ marginTop: 0 }}>Redemption History</h2>
      {loading && <p>Loading history...</p>}
      {!loading && redemptions.length === 0 && <p>No redemptions yet.</p>}
      {!loading && redemptions.length > 0 && (
        <ul style={{ listStyle: "none", padding: 0, margin: 0 }}>
          {redemptions.map((r) => (
            <li
              key={r.id}
              style={{
                padding: "8px 0",
                borderBottom: "1px solid #e5e7eb",
                display: "flex",
                justifyContent: "space-between",
              }}
            >
              <div>
                <div style={{ fontWeight: 500 }}>{r.reward.name}</div>
                <div style={{ fontSize: 12, color: "#6b7280" }}>
                  {r.points_cost} pts • {r.status}
                </div>
              </div>
              <div style={{ fontSize: 12, color: "#6b7280" }}>
                {new Date(r.created_at).toLocaleString()}
              </div>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
};

export default RedemptionHistory;
