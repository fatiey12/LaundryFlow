import express from "express";
import cors from "cors";
import authRoutes from "./modules/auth/auth.routes";
import bookingRoutes from "./modules/booking/booking.routes";
import adminRoutes from "./modules/admin/admin.routes";
import staffRoutes from "./modules/staff/staff.routes";
import path from "path";
import batchRoutes from "./modules/batch/batch.route";
import cycleRoutes from "./modules/cycle/cycle.route";
import walletRoutes from "./modules/wallet/wallet.route";


const app = express();

app.use(cors());
app.use(express.json());

app.use("/api/auth", authRoutes);
app.use("/api/bookings", bookingRoutes);
app.use("/api/admin", adminRoutes);
app.use("/api/staff", staffRoutes);
app.use(express.static(path.join(__dirname, "..")));
app.use("/api/batches", batchRoutes);
app.use("/api/cycles", cycleRoutes);
app.use("/api/wallet", walletRoutes);

app.get("/", (req, res) => {
  res.send("LaundryFlow API is running");
});

export default app;