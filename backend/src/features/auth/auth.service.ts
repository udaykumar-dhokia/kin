import { prisma } from "../../config/prismaClient";
import { hashPassword, verifyPassword } from "../../utils/password.util";
import {
  generateAccessToken,
  generateRefreshToken,
  hashToken,
  getRefreshTokenExpiryDate,
} from "../../utils/token.util";
import type { RegisterInput, LoginInput } from "./auth.validation";

export interface SafeUser {
  id: string;
  email: string;
  firstName: string;
  lastName: string | null;
  avatarUrl: string | null;
  emailVerified: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export interface AuthResponse {
  user: SafeUser;
  accessToken: string;
  refreshToken: string;
  sessionId: string;
}

export class AuthService {
  /**
   * Registers a new user, hashes password with Argon2id, and creates an initial session.
   */
  async register(input: RegisterInput): Promise<AuthResponse> {
    const existingUser = await prisma.user.findUnique({
      where: { email: input.email },
    });

    if (existingUser) {
      const error = new Error("User with this email already exists");
      (error as any).status = 409;
      throw error;
    }

    // Hash password with Argon2id
    const passwordHash = await hashPassword(input.password);

    // Create user in database
    const user = await prisma.user.create({
      data: {
        email: input.email,
        passwordHash,
        firstName: input.firstName,
        lastName: input.lastName || null,
      },
    });

    // Create session and issue tokens
    const rawRefreshToken = generateRefreshToken();
    const refreshTokenHash = hashToken(rawRefreshToken);
    const expiresAt = getRefreshTokenExpiryDate();

    const session = await prisma.session.create({
      data: {
        userId: user.id,
        refreshTokenHash,
        deviceId: input.deviceId || null,
        deviceName: input.deviceName || null,
        expiresAt,
        lastUsedAt: new Date(),
      },
    });

    const accessToken = generateAccessToken({
      userId: user.id,
      email: user.email,
      sessionId: session.id,
    });

    const safeUser: SafeUser = {
      id: user.id,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      avatarUrl: user.avatarUrl,
      emailVerified: user.emailVerified,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    };

    return {
      user: safeUser,
      accessToken,
      refreshToken: rawRefreshToken,
      sessionId: session.id,
    };
  }

  /**
   * Authenticates user credentials using Argon2id and creates an active session.
   */
  async login(input: LoginInput): Promise<AuthResponse> {
    const user = await prisma.user.findUnique({
      where: { email: input.email },
    });

    if (!user) {
      const error = new Error("Invalid email or password");
      (error as any).status = 401;
      throw error;
    }

    // Verify password with Argon2id
    const isPasswordValid = await verifyPassword(
      input.password,
      user.passwordHash,
    );

    if (!isPasswordValid) {
      const error = new Error("Invalid email or password");
      (error as any).status = 401;
      throw error;
    }

    // Create session and issue tokens
    const rawRefreshToken = generateRefreshToken();
    const refreshTokenHash = hashToken(rawRefreshToken);
    const expiresAt = getRefreshTokenExpiryDate();

    const session = await prisma.session.create({
      data: {
        userId: user.id,
        refreshTokenHash,
        deviceId: input.deviceId || null,
        deviceName: input.deviceName || null,
        expiresAt,
        lastUsedAt: new Date(),
      },
    });

    const accessToken = generateAccessToken({
      userId: user.id,
      email: user.email,
      sessionId: session.id,
    });

    const safeUser: SafeUser = {
      id: user.id,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      avatarUrl: user.avatarUrl,
      emailVerified: user.emailVerified,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    };

    return {
      user: safeUser,
      accessToken,
      refreshToken: rawRefreshToken,
      sessionId: session.id,
    };
  }

  /**
   * Refreshes access token and rotates the refresh token for enhanced security.
   */
  async refreshToken(rawRefreshToken: string): Promise<AuthResponse> {
    if (!rawRefreshToken) {
      const error = new Error("Refresh token is required");
      (error as any).status = 400;
      throw error;
    }

    const hashedIncoming = hashToken(rawRefreshToken);

    const session = await prisma.session.findUnique({
      where: { refreshTokenHash: hashedIncoming },
      include: { user: true },
    });

    if (
      !session ||
      session.revokedAt !== null ||
      session.expiresAt < new Date()
    ) {
      const error = new Error(
        "Invalid or expired session. Please log in again.",
      );
      (error as any).status = 401;
      throw error;
    }

    // Rotate refresh token
    const newRawRefreshToken = generateRefreshToken();
    const newRefreshTokenHash = hashToken(newRawRefreshToken);

    const updatedSession = await prisma.session.update({
      where: { id: session.id },
      data: {
        refreshTokenHash: newRefreshTokenHash,
        lastUsedAt: new Date(),
      },
    });

    const accessToken = generateAccessToken({
      userId: session.user.id,
      email: session.user.email,
      sessionId: updatedSession.id,
    });

    const safeUser: SafeUser = {
      id: session.user.id,
      email: session.user.email,
      firstName: session.user.firstName,
      lastName: session.user.lastName,
      avatarUrl: session.user.avatarUrl,
      emailVerified: session.user.emailVerified,
      createdAt: session.user.createdAt,
      updatedAt: session.user.updatedAt,
    };

    return {
      user: safeUser,
      accessToken,
      refreshToken: newRawRefreshToken,
      sessionId: updatedSession.id,
    };
  }

  /**
   * Revokes the specified session.
   */
  async logout(sessionId: string): Promise<void> {
    if (!sessionId) return;

    await prisma.session.updateMany({
      where: { id: sessionId, revokedAt: null },
      data: { revokedAt: new Date() },
    });
  }

  /**
   * Revokes all active sessions for a user (e.g. security reset).
   */
  async logoutAll(userId: string): Promise<void> {
    await prisma.session.updateMany({
      where: { userId, revokedAt: null },
      data: { revokedAt: new Date() },
    });
  }

  /**
   * Retrieves profile data for the current user.
   */
  async getCurrentUser(userId: string): Promise<SafeUser> {
    const user = await prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      const error = new Error("User not found");
      (error as any).status = 404;
      throw error;
    }

    return {
      id: user.id,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      avatarUrl: user.avatarUrl,
      emailVerified: user.emailVerified,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    };
  }
}

export const authService = new AuthService();
