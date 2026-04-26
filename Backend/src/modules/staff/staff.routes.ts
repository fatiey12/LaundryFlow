import { Router } from "express"; 
import { getBoard } from "./staff.controller"; 
import { authMiddleware } from "../../middleware/authMiddleware"; 
import { requireRole } from "../../middleware/role.middleware"; 
const router = Router(); 
router.get("/board", getBoard); 
export default router;