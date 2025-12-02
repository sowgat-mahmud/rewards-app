import { request } from "./client";

export interface User {
  id: number;
  name: string;
  email: string;
  points_balance: number;
}

export function fetchUser(id: number): Promise<User> {
  return request<User>(`/users/${id}`);
}

export function fetchDemoUser(): Promise<User> {
  return request<User>("/users/demo");
}
