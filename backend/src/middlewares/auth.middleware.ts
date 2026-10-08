import type { Request, Response, NextFunction } from "express";
import status from "http-status";
import { verifyAccessToken } from "../utils/token.util";
import { prisma } from "../config/prismaClient";

export interface AuthenticatedUser {
  id: string;
  email: string;
  firstName: string;
  lastName: string | null;
  avatarUrl: string | null;
  emailVerified: boolean;
}

declare global {
  namespace Express {
    interface Request {
      user?: AuthenticatedUser;
      sessionId?: string;
    }
  }
}

/**
 * Authentication middleware that verifies the Bearer access token,
 * validates the active session in the database, and attaches user info to req.user.
 */
export async function authenticate(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    res.status(status.UNAUTHORIZED).json({
      message: "Authorization token required (Format: Bearer <token>)",
    });
    return;
  }

  const token = authHeader.split(" ")[1];
  if (!token) {
    res.status(status.UNAUTHORIZED).json({
      message: "Bearer token missing",
    });
    return;
  }

  try {
    const payload = verifyAccessToken(token);

    // Verify session exists and is active (not revoked, not expired)
    const session = await prisma.session.findUnique({
      where: { id: payload.sessionId },
      include: {
        user: {
          select: {
            id: true,
            email: true,
            firstName: true,
            lastName: true,
            avatarUrl: true,
            emailVerified: true,
          },
        },
      },
    });

    if (
      !session ||
      session.revokedAt !== null ||
      session.expiresAt < new Date()
    ) {
      res.status(status.UNAUTHORIZED).json({
        message: "Session is expired or has been revoked. Please log in again.",
      });
      return;
    }

    if (!session.user) {
      res.status(status.UNAUTHORIZED).json({
        message: "User account no longer exists.",
      });
      return;
    }

    req.user = session.user;
    req.sessionId = session.id;

    next();
  } catch (error) {
    res.status(status.UNAUTHORIZED).json({
      message: "Invalid or expired access token",
    });
  }
}
