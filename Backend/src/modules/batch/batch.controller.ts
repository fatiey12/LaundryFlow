import { Request, Response } from "express";
import { getBatches } from "./batch.service";

export const getBatchesHandler = async (
  req: Request,
  res: Response
) => {
  try {
    const batches = await getBatches();
    res.json(batches);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Error fetching batches" });
  }
};