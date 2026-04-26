import { Router } from "express";
import { register } from "./auth.controller";
import { login } from "./auth.controller";
import { authMiddleware } from "../../middleware/authMiddleware";

const router = Router();

router.post("/register", register);

export default router;
router.post("/login", login);
router.get("/me", authMiddleware, (req, res) => {
  res.json((req as any).user);
});