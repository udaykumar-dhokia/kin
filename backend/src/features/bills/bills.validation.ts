import { z } from "zod";

export const BillCategoryEnum = z.enum([
  "ELECTRICITY",
  "WATER",
  "INTERNET_BROADBAND",
  "RENT",
  "CREDIT_CARD",
  "LOAN_EMI",
  "SUBSCRIPTION",
  "INSURANCE_PREMIUM",
  "EDUCATION_FEES",
  "GAS_UTILITY",
  "TAX",
  "OTHER",
]);

export const BillStatusEnum = z.enum([
  "PENDING",
  "PAID",
  "OVERDUE",
  "CANCELLED",
]);

export const RecurrenceIntervalEnum = z.enum([
  "WEEKLY",
  "BIWEEKLY",
  "MONTHLY",
  "QUARTERLY",
  "HALF_YEARLY",
  "YEARLY",
]);

export const createBillSchema = z
  .object({
    title: z.string().trim().min(1, "Title is required").max(100),
    description: z.string().trim().max(500).optional(),
    category: BillCategoryEnum.default("OTHER"),
    amount: z.coerce.number().positive("Amount must be greater than 0"),
    currency: z
      .string()
      .trim()
      .length(3)
      .transform((v) => v.toUpperCase())
      .default("INR"),
    dueDate: z.coerce.date({ message: "A valid due date is required" }),
    isRecurring: z.boolean().default(false),
    recurrenceInterval: RecurrenceIntervalEnum.optional(),
    notes: z.string().trim().max(1000).optional(),
  })
  .refine(
    (data) =>
      !data.isRecurring || (data.isRecurring && !!data.recurrenceInterval),
    {
      message: "Recurrence interval is required when isRecurring is true",
      path: ["recurrenceInterval"],
    },
  );

export const updateBillSchema = z
  .object({
    title: z.string().trim().min(1).max(100).optional(),
    description: z.string().trim().max(500).optional().nullable(),
    category: BillCategoryEnum.optional(),
    amount: z.coerce.number().positive().optional(),
    currency: z
      .string()
      .trim()
      .length(3)
      .transform((v) => v.toUpperCase())
      .optional(),
    dueDate: z.coerce.date().optional(),
    status: BillStatusEnum.optional(),
    isRecurring: z.boolean().optional(),
    recurrenceInterval: RecurrenceIntervalEnum.optional().nullable(),
    notes: z.string().trim().max(1000).optional().nullable(),
  })
  .refine(
    (data) =>
      data.isRecurring === undefined ||
      !data.isRecurring ||
      (data.isRecurring && !!data.recurrenceInterval),
    {
      message: "Recurrence interval is required when isRecurring is true",
      path: ["recurrenceInterval"],
    },
  );

export const payBillSchema = z.object({
  paidAmount: z.coerce.number().positive().optional(),
  paymentMethod: z.string().trim().max(50).optional(),
  paidAt: z.coerce.date().default(() => new Date()),
});

export const queryBillsSchema = z.object({
  status: BillStatusEnum.optional(),
  category: BillCategoryEnum.optional(),
  isRecurring: z
    .string()
    .transform((val) => val === "true")
    .optional(),
  from: z.coerce.date().optional(),
  to: z.coerce.date().optional(),
  search: z.string().trim().optional(),
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().positive().max(100).default(20),
});

export const uploadAttachmentSchema = z.object({
  type: z.enum(["invoice", "receipt"], {
    message: "Attachment type must be either 'invoice' or 'receipt'",
  }),
});

export type CreateBillInput = z.infer<typeof createBillSchema>;
export type UpdateBillInput = z.infer<typeof updateBillSchema>;
export type PayBillInput = z.infer<typeof payBillSchema>;
export type QueryBillsInput = z.infer<typeof queryBillsSchema>;
export type UploadAttachmentInput = z.infer<typeof uploadAttachmentSchema>;
