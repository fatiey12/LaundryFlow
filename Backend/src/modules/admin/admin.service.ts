import prisma from "../../config/prisma";

  export const getDashboardStats = async () => {
  const totalBookings = await prisma.booking.count();
  const totalCycles = await prisma.cycle.count();

  const machines = await prisma.machine.findMany({
    include: { cycles: true },
  });

  // Utilization %
  const utilization = machines.map((m) => ({
    machineId: m.id,
    building: m.building,
    usage: m.cycles.length,
  }));

  // Avg completion time
  const cycles = await prisma.cycle.findMany({
    where: {
      startTime: { not: null },
      endTime: { not: null },
    },
  });

  const avgTime =
    cycles.reduce((acc, c) => {
      const diff =
        new Date(c.endTime!).getTime() -
        new Date(c.startTime!).getTime();
      return acc + diff;
    }, 0) / (cycles.length || 1);

  return {
    totalBookings,
    totalCycles,
    avgCompletionMinutes: Math.round(avgTime / 60000),
    utilization,
  };
};
