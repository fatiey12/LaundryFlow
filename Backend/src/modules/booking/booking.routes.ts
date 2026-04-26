import express from "express";
import { authMiddleware } from "../../middleware/authMiddleware";
import {
  createBookingHandler,
  getMyBookings,
} from "./booking.controller";

import prisma from "../../config/prisma";
import { createBooking } from "./booking.service";

const router = express.Router();



// Normal student booking

router.post("/", authMiddleware, createBookingHandler);



// Walk-in booking

router.post("/walkin", async (req, res) => {
  try {
    const { studentId, weight } = req.body;

    const user = await prisma.user.findFirst({
      where: { studentId },
    });

    const result = await createBooking(
      user?.id || null,
      Number(weight)
    );

    await prisma.booking.update({
      where: { id: result.booking.id },
      data: {
        studentId: studentId, //force save
      },
    });

    res.json({
      message: "Walk-in booking created",
    });

  } catch (error) {
    console.error(error);
    res.status(500).json({
      message: "Walk-in failed",
    });
  }
});

// My bookings

router.get("/my", authMiddleware, getMyBookings);

export default router;