import prisma from "../src/config/prisma";
import { MachineType } from "@prisma/client";

async function main() {
  console.log("🌱 Seeding machines...");

  const machines = [];

  // Building 36
  for (let i = 0; i < 9; i++) {
    machines.push({
      type: MachineType.WASHER,
      building: "36",
    });

    machines.push({
      type: MachineType.DRYER,
      building: "36",
    });
  }

  // Building 39
  for (let i = 0; i < 8; i++) {
    machines.push({
      type: MachineType.WASHER,
      building: "39",
    });

    machines.push({
      type: MachineType.DRYER,
      building: "39",
    });
  }

  await prisma.machine.createMany({
    data: machines,
  });

  console.log("✅ Machines seeded successfully");
}

main()
  .catch((e) => {
    console.error(e);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });