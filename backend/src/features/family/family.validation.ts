import { z } from "zod";

export const FamilyRelationshipEnum = z.enum([
  "SELF",
  "SPOUSE",
  "FATHER",
  "MOTHER",
  "SON",
  "DAUGHTER",
  "BROTHER",
  "SISTER",
  "OTHER",
]);

export const HouseholdRoleEnum = z.enum(["OWNER", "ADMIN", "MEMBER"]);

export const InvitationStatusEnum = z.enum([
  "PENDING",
  "ACCEPTED",
  "DECLINED",
  "EXPIRED",
  "CANCELLED",
]);

export const createMemberSchema = z.object({
  name: z.string().trim().min(1, "Name is required").max(100),
  relationship: FamilyRelationshipEnum.default("OTHER"),
  role: HouseholdRoleEnum.default("MEMBER"),
  dateOfBirth: z.coerce.date().optional(),
  color: z
    .string()
    .trim()
    .regex(
      /^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/,
      "Color must be a valid hex code (e.g. #4F46E5)",
    )
    .optional(),
  notes: z.string().trim().max(500).optional(),
});

export const updateMemberSchema = z.object({
  name: z.string().trim().min(1).max(100).optional(),
  relationship: FamilyRelationshipEnum.optional(),
  role: HouseholdRoleEnum.optional(),
  dateOfBirth: z.coerce.date().optional().nullable(),
  color: z
    .string()
    .trim()
    .regex(/^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/)
    .optional()
    .nullable(),
  notes: z.string().trim().max(500).optional().nullable(),
});

export const updateHouseholdSchema = z.object({
  name: z
    .string()
    .trim()
    .min(1, "Household name is required")
    .max(100)
    .optional(),
  currency: z
    .string()
    .trim()
    .length(3)
    .transform((v) => v.toUpperCase())
    .optional(),
});

export const createInvitationSchema = z.object({
  email: z
    .string()
    .trim()
    .toLowerCase()
    .email("A valid email address is required for sending an invitation"),
  name: z.string().trim().min(1, "Name is required").max(100),
  relationship: FamilyRelationshipEnum.default("SPOUSE"),
  role: HouseholdRoleEnum.default("MEMBER"),
});

export const acceptInvitationSchema = z.object({
  token: z.string().trim().min(1, "Invitation token is required"),
});

export type CreateMemberInput = z.infer<typeof createMemberSchema>;
export type UpdateMemberInput = z.infer<typeof updateMemberSchema>;
export type UpdateHouseholdInput = z.infer<typeof updateHouseholdSchema>;
export type CreateInvitationInput = z.infer<typeof createInvitationSchema>;
export type AcceptInvitationInput = z.infer<typeof acceptInvitationSchema>;
