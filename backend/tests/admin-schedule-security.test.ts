import request from "supertest";
import { beforeEach, describe, expect, it, vi } from "vitest";

const mocks = vi.hoisted(() => ({
  tripScheduleItemFindFirst: vi.fn(),
  tripScheduleItemUpdate: vi.fn(),
  tripScheduleDayFindFirst: vi.fn(),
  tripScheduleDayFindUnique: vi.fn(),
}));

vi.mock("../src/config/prisma.js", () => ({
  default: {
    tripScheduleItem: {
      findFirst: mocks.tripScheduleItemFindFirst,
      update: mocks.tripScheduleItemUpdate,
    },
    tripScheduleDay: {
      findFirst: mocks.tripScheduleDayFindFirst,
      findUnique: mocks.tripScheduleDayFindUnique,
    },
  },
}));

import { app } from "../src/app.js";

const adminAuth = `Basic ${Buffer.from("admin:test-admin_password").toString("base64")}`;

describe("admin schedule security", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("rejects updating a schedule item that does not belong to the trip", async () => {
    mocks.tripScheduleItemFindFirst.mockResolvedValue(null);

    const res = await request(app)
      .put("/api/admin/trips/trip-1/schedule/items/item-1")
      .set("Authorization", adminAuth)
      .send({ dayId: "day-other", startTime: "08:00", title: "Updated" });

    expect(res.status).toBe(404);
    expect(mocks.tripScheduleItemUpdate).not.toHaveBeenCalled();
  });
});
