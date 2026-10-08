import { z } from "zod";

export const registerSchema = z.object({
  email: z
    .string()
    .trim()
    .toLowerCase()
    .email({ message: "Invalid email address format" }),
  password: z
    .string()
    .min(8, { message: "Password must be at least 8 characters long" })
    .max(100, { message: "Password must not exceed 100 characters" }),
  firstName: z
    .string()
    .trim()
    .min(1, { message: "First name is required" })
    .max(50, { message: "First name must not exceed 50 characters" }),
  lastName: z
    .string()
    .trim()
    .max(50, { message: "Last name must not exceed 50 characters" })
    .optional(),
  deviceId: z.string().trim().optional(),
  deviceName: z.string().trim().optional(),
});

export const loginSchema = z.object({
  email: z
    .string()
    .trim()
    .toLowerCase()
    .email({ message: "Invalid email address format" }),
  password: z.string().min(1, { message: "Password is required" }),
  deviceId: z.string().trim().optional(),
  deviceName: z.string().trim().optional(),
});

export const refreshTokenSchema = z.object({
  refreshToken: z.string().trim().optional(),
});

export type RegisterInput = z.infer<typeof registerSchema>;
export type LoginInput = z.infer<typeof loginSchema>;
export type RefreshTokenInput = z.infer<typeof refreshTokenSchema>;
