import type { Request, Response } from "express";
import status from "http-status";
import { ZodError } from "zod";
import { authService } from "./auth.service";
import {
  registerSchema,
  loginSchema,
  refreshTokenSchema,
} from "./auth.validation";
import { getRefreshTokenCookieOptions } from "../../utils/token.util";

export class AuthController {
  /**
   * Handle user registration.
   */
  async register(req: Request, res: Response): Promise<void> {
    try {
      const validatedData = registerSchema.parse(req.body);
      const result = await authService.register(validatedData);

      // Set HTTP-only secure cookie for web clients
      res.cookie(
        "refreshToken",
        result.refreshToken,
        getRefreshTokenCookieOptions(),
      );

      res.status(status.CREATED).json({
        message: "User registered successfully",
        user: result.user,
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      });
    } catch (error: any) {
      if (error instanceof ZodError) {
        res.status(status.BAD_REQUEST).json({
          message: "Validation failed",
          errors: error.issues.map((i) => ({
            field: i.path.join("."),
            message: i.message,
          })),
        });
        return;
      }

      res.status(error.status || status.INTERNAL_SERVER_ERROR).json({
        message: error.message || "An error occurred during registration",
      });
    }
  }

  /**
   * Handle user login.
   */
  async login(req: Request, res: Response): Promise<void> {
    try {
      const validatedData = loginSchema.parse(req.body);
      const result = await authService.login(validatedData);

      // Set HTTP-only secure cookie for web clients
      res.cookie(
        "refreshToken",
        result.refreshToken,
        getRefreshTokenCookieOptions(),
      );

      res.status(status.OK).json({
        message: "Login successful",
        user: result.user,
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      });
    } catch (error: any) {
      if (error instanceof ZodError) {
        res.status(status.BAD_REQUEST).json({
          message: "Validation failed",
          errors: error.issues.map((i) => ({
            field: i.path.join("."),
            message: i.message,
          })),
        });
        return;
      }

      res.status(error.status || status.INTERNAL_SERVER_ERROR).json({
        message: error.message || "An error occurred during login",
      });
    }
  }

  /**
   * Handle token refresh and rotation.
   * Accepts refresh token from cookie or request body for multi-client support.
   */
  async refreshToken(req: Request, res: Response): Promise<void> {
    try {
      // Check cookies first, then body, then headers
      const rawToken =
        req.cookies?.refreshToken ||
        req.body?.refreshToken ||
        req.headers["x-refresh-token"];

      if (!rawToken || typeof rawToken !== "string") {
        res.status(status.BAD_REQUEST).json({
          message: "Refresh token is missing from request",
        });
        return;
      }

      const result = await authService.refreshToken(rawToken);

      // Set rotated refresh token in cookie
      res.cookie(
        "refreshToken",
        result.refreshToken,
        getRefreshTokenCookieOptions(),
      );

      res.status(status.OK).json({
        message: "Token refreshed successfully",
        user: result.user,
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      });
    } catch (error: any) {
      res.status(error.status || status.UNAUTHORIZED).json({
        message: error.message || "Failed to refresh token",
      });
    }
  }

  /**
   * Handle user logout (revokes current session and clears cookie).
   */
  async logout(req: Request, res: Response): Promise<void> {
    try {
      const sessionId = req.sessionId;

      if (sessionId) {
        await authService.logout(sessionId);
      }

      // Clear the cookie
      res.clearCookie("refreshToken", getRefreshTokenCookieOptions());

      res.status(status.OK).json({
        message: "Logged out successfully",
      });
    } catch (error: any) {
      res.status(status.INTERNAL_SERVER_ERROR).json({
        message: error.message || "Failed to log out",
      });
    }
  }

  /**
   * Get current authenticated user details.
   */
  async me(req: Request, res: Response): Promise<void> {
    if (!req.user) {
      res.status(status.UNAUTHORIZED).json({
        message: "Unauthorized",
      });
      return;
    }

    res.status(status.OK).json({
      user: req.user,
    });
  }
}

export const authController = new AuthController();
