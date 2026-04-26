import express from "express";
import prisma from "../../config/prisma";
import { io } from "../../server";

const router = express.Router();

router.get("/stats", async (req, res) => {
  try {
    const totalBookings = await prisma.booking.count();

    const completed = await prisma.cycle.count({
      where: { status: "COMPLETED" },
    });

    const active = await prisma.cycle.count({
      where: { status: "ACTIVE" },
    });

    const building36 = await prisma.machine.count({
      where: { building: "36" },
    });

    const building39 = await prisma.machine.count({
      where: { building: "39" },
    });

    const walkins = await prisma.booking.count({
      where: {
        studentId: { not: null },
        userId: null,
      },
    });


    router.post("/announce", async (req, res) => {
  try {
    const { title, message } = req.body;

    const announcement =
      await prisma.announcement.create({
        data: { title, message },
      });

    io.emit("announcement", announcement);

    res.json({
      message: "Announcement sent",
      announcement,
    });

  } catch (error) {
    res.status(500).json({
      message: "Failed to send announcement",
    });
  }
});
    res.json({
      totalBookings,
      active,
      completed,
      building36,
      building39,
      walkins,
    });

  } catch (error) {
    res.status(500).json({
      message: "Admin stats error",
    });
  }
});

export default router;