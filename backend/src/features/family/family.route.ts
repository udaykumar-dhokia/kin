import express from "express";
import { familyController } from "./family.controller";
import { authenticate } from "../../middlewares/auth.middleware";
import { uploadSingleImage } from "../../middlewares/upload.middleware";

const router = express.Router();

// All family routes require authentication
router.use(authenticate);

// Household endpoints
router.get("/", (req, res) => familyController.getHousehold(req, res));
router.patch("/", (req, res) => familyController.updateHousehold(req, res));

// Member management endpoints
router.post("/members", (req, res) => familyController.addMember(req, res));
router.get("/members/:id", (req, res) => familyController.getMemberById(req, res));
router.patch("/members/:id", (req, res) => familyController.updateMember(req, res));
router.delete("/members/:id", (req, res) => familyController.removeMember(req, res));
router.post(
  "/members/:id/avatar",
  uploadSingleImage("avatar"),
  (req, res) => familyController.uploadMemberAvatar(req, res)
);
router.get("/members/:id/bills", (req, res) => familyController.getMemberBills(req, res));

// Invitation workflows (collaborative viral loop)
router.post("/invitations", (req, res) => familyController.inviteMember(req, res));
router.post("/invitations/accept", (req, res) => familyController.acceptInvitation(req, res));
router.delete("/invitations/:id", (req, res) => familyController.cancelInvitation(req, res));

export default router;
