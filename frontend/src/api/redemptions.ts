import { request } from "./client";

export type RedemptionStatus = "pending" | "completed" | "failed";

export interface Redemption {
  id: number;
  status: RedemptionStatus;
  points_cost: number;
  reward: {
    id: number;
    name: string;
  };
  created_at: string;
}

export interface CreateRedemptionResponse {
  redemption: Redemption;
  user: {
    id: number;
    points_balance: number;
  };
}

export function fetchUserRedemptions(userId: number): Promise<Redemption[]> {
  return request<Redemption[]>(`/users/${userId}/redemptions`);
}

// POST /api/v1/redemptions (sync Redeemer)
export function createRedemption(userId: number, rewardId: number) {
  return request<CreateRedemptionResponse>("/redemptions", {
    method: "POST",
    body: JSON.stringify({
      redemption: {
        user_id: userId,
        reward_id: rewardId,
      },
    }),
  });
}
