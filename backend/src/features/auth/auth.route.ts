import express from "express";
import { authController } from "./auth.controller";
import { authenticate } from "../../middlewares/auth.middleware";

const router = express.Router();

// Public auth endpoints
router.post("/register", (req, res) => authController.register(req, res));
router.post("/login", (req, res) => authController.login(req, res));
router.post("/refresh", (req, res) => authController.refreshToken(req, res));

// Protected auth endpoints
router.post("/logout", authenticate, (req, res) =>
  authController.logout(req, res),
);
router.get("/me", authenticate, (req, res) => authController.me(req, res));

export default router;
