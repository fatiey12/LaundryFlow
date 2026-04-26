import express from "express";
import { getBatchesHandler } from "./batch.controller";

const router = express.Router();

router.get("/", getBatchesHandler);

export default router;