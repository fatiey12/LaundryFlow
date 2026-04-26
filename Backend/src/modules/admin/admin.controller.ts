import { Request, Response } from "express";
import { getDashboardStats } from "./admin.service";

export const getStats = async (req: Request, res: Response) => {
  try {
    const stats = await getDashboardStats();
    res.json(stats);
  } catch (error) {
    res.status(500).json({ message: "Error fetching stats" });
  }
};