import prisma from "../../config/prisma";

export const getStaffBoard = async () => {
  const cycles = await prisma.cycle.findMany({
    include: {
      booking: {
        include: {
          user: true,
        },
      },
      machine: true,
    },
    orderBy: {
      startTime: "asc",
    },
  });

  // ARRAYS
  const active: any[] = [];
  const completed: any[] = [];

  // ONLY USE STATUS (NOT TIME)
  for (const cycle of cycles) {
    if (cycle.status === "COMPLETED") {
      completed.push(cycle);
    } else {
      active.push(cycle); // everything else stays active
    }
  }

  // GROUP ACTIVE BY BATCH
  const activeGrouped: any = {};

  for (const cycle of active) {
    const batch = cycle.booking?.batchId || "N/A";

    if (!activeGrouped[batch]) {
      activeGrouped[batch] = [];
    }

    activeGrouped[batch].push(cycle);
  }

  return {
    active,            // keep for compatibility
    activeGrouped,    
    completed,
  };
};