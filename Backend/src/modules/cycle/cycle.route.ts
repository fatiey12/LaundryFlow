import express from "express";
import prisma from "../../config/prisma";
import { io } from "../../server";
import { getStaffBoard } from "../staff/staff.service";

const router = express.Router();

//MARKING CYCLE AS COMPLETED
router.patch("/:id/complete", async (req, res) => {
  try {
    const { id } = req.params;

    // Update status
    await prisma.cycle.update({
      where: { id },
      data: { status: "COMPLETED" },
    });

    // Get cycle with booking
    const cycle = await prisma.cycle.findUnique({
      where: { id },
      include: {
        booking: true,
      },
    });

    // Emit staff dashboard update
    const updatedBoard = await getStaffBoard();
    io.emit("staff-board-update", updatedBoard);

    // Emit notification to user
    io.emit("laundry-ready", {
      userId: cycle?.booking.userId,
    });

    res.json({ message: "Cycle marked as completed" });

  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Error completing cycle" });
  }
});

export default router;