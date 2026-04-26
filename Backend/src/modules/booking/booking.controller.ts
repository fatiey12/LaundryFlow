import { Request, Response } from "express";
import { createBooking } from "./booking.service";
import prisma from "../../config/prisma";

// CREATE BOOKING (supports BOTH app + walk-in)
export const createBookingHandler = async (
  req: Request,
  res: Response
) => {
  try {
    const user = (req as any).user;

    // support both logged-in and walk-in
    const userId = user?.id || req.body.userId;
    const { weight, batchId } = req.body;

    if (!userId || !weight) {
      return res.status(400).json({
        message: "userId and weight are required",
      });
    }

    const result = await createBooking(userId, weight, batchId);

    res.status(201).json(result);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Error creating booking" });
  }
};

// GET USER BOOKINGS
export const getMyBookings = async (req: any, res: any) => {
  try {
    const userId = req.user.id;

    const bookings = await prisma.booking.findMany({
      where: { userId },
      orderBy: { createdAt: "desc" },
      include: {
        cycles: true,
      },
    });

    res.json(bookings);
  } catch (err) {
    res.status(500).json({ message: "Error fetching bookings" });
  }
};