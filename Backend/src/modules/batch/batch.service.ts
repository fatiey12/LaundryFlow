import prisma from "../../config/prisma";

export const getBatches = async () => {
  //  Define batches
  const batches = [
    { id: "A", start: 8, end: 10 },
    { id: "B", start: 10, end: 12 },
    { id: "C", start: 12, end: 14 },
    { id: "D", start: 14, end: 16 },
  ];

  // Count machines
  const washers = await prisma.machine.count({
    where: { type: "WASHER", isActive: true },
  });

  const dryers = await prisma.machine.count({
    where: { type: "DRYER", isActive: true },
  });

  const capacity = Math.min(washers, dryers);

  const result = [];

  for (const batch of batches) {
    // Count bookings in this batch (for now faking = 0)
    const booked = await prisma.booking.count({
  where: {
    batchId: batch.id,
  },
});

    result.push({
      ...batch,
      capacity,
      booked,
      isFull: booked >= capacity,
    });
  }

  return result;
};