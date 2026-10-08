import express from "express";
import { billsController } from "./bills.controller";
import { authenticate } from "../../middlewares/auth.middleware";
import { uploadSingleImage } from "../../middlewares/upload.middleware";

const router = express.Router();

// All bill routes require authentication
router.use(authenticate);

// Attention Dashboard (must be declared before /:id)
router.get("/dashboard", (req, res) => billsController.getDashboard(req, res));

// Bills CRUD
router.get("/", (req, res) => billsController.getBills(req, res));
router.post("/", (req, res) => billsController.createBill(req, res));
router.get("/:id", (req, res) => billsController.getBillById(req, res));
router.patch("/:id", (req, res) => billsController.updateBill(req, res));
router.delete("/:id", (req, res) => billsController.deleteBill(req, res));

// Actions
router.post("/:id/pay", (req, res) => billsController.payBill(req, res));
router.post("/:id/attachments", uploadSingleImage("file"), (req, res) =>
  billsController.uploadAttachment(req, res),
);

export default router;
