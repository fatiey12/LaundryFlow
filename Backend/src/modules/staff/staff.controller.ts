
import { Request, Response } from "express";
import { getStaffBoard } from "./staff.service";

export const getBoard = async (req: Request, res: Response) => {
  try {
    const data = await getStaffBoard();

    res.json(data);
  } catch (error) {
    console.error("STAFF BOARD ERROR:", error);

    res.status(500).json({
      message: "Error fetching board",
      error: (error as any).message,
    });
  }
};