import express from "express";
import { authMiddleware }
from "../../middleware/authMiddleware";

import {
  getBalance,
  topUpWallet,
  getHistory,
} from "./wallet.controller";

const router = express.Router();

router.get(
  "/balance",
  authMiddleware,
  getBalance
);

router.post(
  "/topup",
  authMiddleware,
  topUpWallet
);

router.get(
  "/history",
  authMiddleware,
  getHistory
);

export default router;