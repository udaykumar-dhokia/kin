import jwt from "jsonwebtoken";
import crypto from "crypto";
import type { CookieOptions } from "express";

export interface AccessTokenPayload {
  userId: string;
  email: string;
  sessionId: string;
}

const JWT_ACCESS_SECRET =
  process.env.JWT_ACCESS_SECRET ||
  "default_development_jwt_secret_change_me_in_production";
const JWT_ACCESS_EXPIRES_IN = process.env.JWT_ACCESS_EXPIRES_IN || "15m";
const REFRESH_TOKEN_EXPIRES_DAYS = parseInt(
  process.env.REFRESH_TOKEN_EXPIRES_DAYS || "7",
  10,
);

/**
 * Signs a short-lived access JWT for authenticated requests.
 */
export function generateAccessToken(payload: AccessTokenPayload): string {
  const options: jwt.SignOptions = {
    expiresIn: (JWT_ACCESS_EXPIRES_IN || "15m") as any,
  };
  return jwt.sign(payload, JWT_ACCESS_SECRET, options);
}

/**
 * Verifies and decodes an access JWT token.
 * Throws JsonWebTokenError or TokenExpiredError on invalid token.
 */
export function verifyAccessToken(token: string): AccessTokenPayload {
  return jwt.verify(token, JWT_ACCESS_SECRET) as AccessTokenPayload;
}

/**
 * Generates an opaque, cryptographically secure random refresh token.
 */
export function generateRefreshToken(): string {
  return crypto.randomBytes(40).toString("hex");
}

/**
 * Hashes a token using SHA-256 for secure database storage.
 * Follows OWASP recommendation: Store only hashes of session tokens in database.
 */
export function hashToken(token: string): string {
  return crypto.createHash("sha256").update(token).digest("hex");
}

/**
 * Calculates the expiration date for a new refresh token.
 */
export function getRefreshTokenExpiryDate(): Date {
  const expiresAt = new Date();
  expiresAt.setDate(expiresAt.getDate() + REFRESH_TOKEN_EXPIRES_DAYS);
  return expiresAt;
}

/**
 * Cookie configuration options for storing the refresh token securely in browsers.
 */
export function getRefreshTokenCookieOptions(): CookieOptions {
  const isProduction = process.env.NODE_ENV === "production";
  return {
    httpOnly: true,
    secure: isProduction,
    sameSite: isProduction ? "strict" : "lax",
    maxAge: REFRESH_TOKEN_EXPIRES_DAYS * 24 * 60 * 60 * 1000,
    path: "/",
  };
}
