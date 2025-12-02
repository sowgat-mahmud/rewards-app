import React from "react";
import type { User } from "../api/users";

interface BalancePanelProps {
  user: User | null;
  loading: boolean;
}

const BalancePanel: React.FC<BalancePanelProps> = ({ user, loading }) => {
  return (
    <div style={{ padding: 16, borderRadius: 8, border: "1px solid #e5e7eb", marginBottom: 16 }}>
      <h2 style={{ margin: 0, marginBottom: 8 }}>Points Balance</h2>
      {loading && <p>Loading...</p>}
      {!loading && user && (
        <>
          <p style={{ margin: 0 }}>{user.name}</p>
          <p style={{ margin: 0, fontSize: 24, fontWeight: "bold" }}>
            {user.points_balance} pts
          </p>
        </>
      )}
    </div>
  );
};

export default BalancePanel;
