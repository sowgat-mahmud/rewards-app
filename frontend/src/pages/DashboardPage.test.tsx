import { describe, it, expect, beforeEach, afterEach, vi } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import DashboardPage from "./DashboardPage";

type FetchFn = (input: RequestInfo | URL, init?: RequestInit) => Promise<Response>;

const originalFetch = globalThis.fetch as FetchFn | undefined;

describe("DashboardPage", () => {
  beforeEach(() => {
    vi.resetAllMocks();

    const mockFetch: FetchFn = async () => {
      throw new Error("User API failed");
    };

    globalThis.fetch = mockFetch as unknown as FetchFn;
  });

  afterEach(() => {
    vi.resetAllMocks();

    if (originalFetch) {
      globalThis.fetch = originalFetch;
    } else {
      delete (globalThis as Record<string, unknown>).fetch;
    }
  });

  it("shows an error banner when the user API fails", async () => {
    render(<DashboardPage />);

    await waitFor(() => {
      expect(
        screen.getByText(/Failed to load dashboard/i)
      ).toBeInTheDocument();
    });
  });
});
