import { request } from "./client";

export type RewardCategory = "gift_card" | "merchandise" | "experience";

export interface Reward {
  id: number;
  name: string;
  cost_in_points: number;
  inventory: number;
  category: RewardCategory;
  available: boolean;
}

export function fetchRewards(): Promise<Reward[]> {
  return request<Reward[]>("/rewards");
}
