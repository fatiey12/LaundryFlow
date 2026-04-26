import prisma from "../../config/prisma";
import { io } from "../../server";
import { getStaffBoard } from "../staff/staff.service";
import { predictDelay } from "../../utils/predict";
import { MachineType } from "@prisma/client";

const MAX_CAPACITY = 7;
const PRICE_PER_CYCLE = 10;

const AVG_WASH_TIME = 60;
const AVG_DRY_TIME = 40;

// =======================================
// Choose less busy building
// =======================================
const getBestBuilding = async (): Promise<"36" | "39"> => {
  const cycles = await prisma.cycle.findMany({
    include: { machine: true },
  });

  let load36 = 0;
  let load39 = 0;

  for (const cycle of cycles) {
    if (cycle.machine?.building === "36") load36++;
    if (cycle.machine?.building === "39") load39++;
  }

  return load36 <= load39 ? "36" : "39";
};

// =======================================
// MAIN BOOKING
// =======================================
export async function createBooking(
  userId: string | null,
  weight: number,
  batchId?: string
) {
  // ==========================
  // COST LOGIC
  // ==========================
  const washerCycles = Math.ceil(weight / 7);
  const dryerCycles = 1;

  const totalCycles =
    washerCycles + dryerCycles;

  const totalCost =
    totalCycles * PRICE_PER_CYCLE;

  // ==========================
  // CHECK WALLET (ONLY FOR REGISTERED USERS)
  // ==========================
  if (userId) {
    const user =
      await prisma.user.findUnique({
        where: { id: userId },
      });

    if (!user) {
      throw new Error(
        "User not found"
      );
    }

    if (
      user.walletBalance <
      totalCost
    ) {
      throw new Error(
        `Insufficient wallet balance. Need ${totalCost} DH`
      );
    }

    // Deduct wallet
    await prisma.user.update({
      where: { id: userId },
      data: {
        walletBalance: {
          decrement: totalCost,
        },
      },
    });

    // Save transaction
    await prisma.walletTransaction.create(
      {
        data: {
          userId,
          amount: totalCost,
          type: "BOOKING_PAYMENT",
          note: `${washerCycles} wash + 1 dryer`,
        },
      }
    );
  }

  // ==========================
  // CREATE BOOKING
  // ==========================
  const booking =
    await prisma.booking.create({
      data: {
        userId,
        weight,
        batchId,
        status: "PENDING",
      },
    });

  // ==========================
  // SPLIT WASH LOADS
  // ==========================
  const washLoads: number[] = [];

  let remaining = weight;

  while (remaining > 0) {
    const load = Math.min(
      remaining,
      MAX_CAPACITY
    );

    washLoads.push(load);
    remaining -= load;
  }

  // ==========================
  // PREDICTION
  // ==========================
  const queueLength =
    await prisma.booking.count({
      where: {
        status: "PENDING",
      },
    });

  const prediction =
    predictDelay({
      queueLength,
      cycles: totalCycles,
      timeOfDay:
        new Date().getHours(),
    });

  // ==========================
  // MACHINE SELECTION
  // ==========================
  const bestBuilding =
    await getBestBuilding();

  const washers =
    await prisma.machine.findMany({
      where: {
        type: MachineType.WASHER,
        building:
          bestBuilding,
        isActive: true,
      },
      include: {
        cycles: true,
      },
    });

  const dryers =
    await prisma.machine.findMany({
      where: {
        type: MachineType.DRYER,
        building:
          bestBuilding,
        isActive: true,
      },
      include: {
        cycles: true,
      },
    });

  if (
    washers.length === 0 ||
    dryers.length === 0
  ) {
    throw new Error(
      "Machines unavailable"
    );
  }

  // ==========================
  // CREATE WASH CYCLES
  // ==========================
  let lastWashEnd =
    new Date();

  for (const load of washLoads) {
    const washer =
      washers[0];

    const start =
      new Date(
        lastWashEnd
      );

    const end =
      new Date(
        start.getTime() +
          AVG_WASH_TIME *
            60000
      );

    await prisma.cycle.create({
      data: {
        bookingId:
          booking.id,
        machineId:
          washer.id,
        weight: load,
        startTime:
          start,
        endTime: end,
      },
    });

    lastWashEnd = end;
  }

  // ==========================
  // ONE DRYER CYCLE
  // ==========================
  const dryer =
    dryers[0];

  const dryStart =
    new Date(
      lastWashEnd
    );

  const dryEnd =
    new Date(
      dryStart.getTime() +
        AVG_DRY_TIME *
          60000
    );

  await prisma.cycle.create({
    data: {
      bookingId:
        booking.id,
      machineId:
        dryer.id,
      weight: weight,
      startTime:
        dryStart,
      endTime:
        dryEnd,
    },
  });

  // ==========================
  // READY TIME
  // ==========================
  const estimatedReadyTime =
    dryEnd.toLocaleTimeString(
      [],
      {
        hour: "2-digit",
        minute:
          "2-digit",
      }
    );

  // ==========================
  // LIVE UPDATE
  // ==========================
  const board =
    await getStaffBoard();

  io.emit(
    "staff-board-update",
    board
  );

  // ==========================
  // RETURN
  // ==========================
  return {
    booking,
    building:
      bestBuilding,
    prediction,
    estimatedReadyTime,

    pricing: {
      washerCycles,
      dryerCycles,
      totalCycles,
      totalCost,
    },

    message:
      "Booking confirmed successfully",
  };
}