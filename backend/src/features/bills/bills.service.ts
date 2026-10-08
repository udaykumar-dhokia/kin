import { prisma } from "../../config/prismaClient";
import {
  Prisma,
  type Bill,
  type RecurrenceInterval,
} from "../../../generated/prisma/client";
import {
  cloudinaryService,
  extractPublicIdFromUrl,
} from "../../utils/cloudinary.util";
import type {
  CreateBillInput,
  UpdateBillInput,
  PayBillInput,
  QueryBillsInput,
} from "./bills.validation";

export interface DashboardMetrics {
  totalPendingAmount: number;
  overdueCount: number;
  dueSoonCount: number;
  upcomingCount: number;
  currency: string;
}

export interface DashboardData {
  overdue: Bill[];
  dueSoon: Bill[];
  upcoming: Bill[];
  metrics: DashboardMetrics;
}

export class BillsService {
  /**
   * Calculates the next due date based on the recurrence interval.
   */
  public calculateNextDueDate(
    currentDueDate: Date,
    interval: RecurrenceInterval,
  ): Date {
    const next = new Date(currentDueDate);

    switch (interval) {
      case "WEEKLY":
        next.setDate(next.getDate() + 7);
        break;
      case "BIWEEKLY":
        next.setDate(next.getDate() + 14);
        break;
      case "MONTHLY": {
        const currentMonth = next.getMonth();
        next.setMonth(currentMonth + 1);
        break;
      }
      case "QUARTERLY": {
        const currentMonth = next.getMonth();
        next.setMonth(currentMonth + 3);
        break;
      }
      case "HALF_YEARLY": {
        const currentMonth = next.getMonth();
        next.setMonth(currentMonth + 6);
        break;
      }
      case "YEARLY":
        next.setFullYear(next.getFullYear() + 1);
        break;
    }

    return next;
  }

  /**
   * Creates a new bill for the authenticated user.
   */
  async createBill(userId: string, input: CreateBillInput): Promise<Bill> {
    return prisma.bill.create({
      data: {
        userId,
        title: input.title,
        description: input.description || null,
        category: input.category,
        amount: new Prisma.Decimal(input.amount),
        currency: input.currency,
        dueDate: input.dueDate,
        isRecurring: input.isRecurring,
        recurrenceInterval: input.isRecurring ? input.recurrenceInterval : null,
        notes: input.notes || null,
      },
    });
  }

  /**
   * Retrieves a paginated list of bills with optional filters.
   */
  async getBills(userId: string, query: QueryBillsInput) {
    const where: Prisma.BillWhereInput = {
      userId,
    };

    if (query.status) {
      where.status = query.status;
    }

    if (query.category) {
      where.category = query.category;
    }

    if (query.isRecurring !== undefined) {
      where.isRecurring = query.isRecurring;
    }

    if (query.from || query.to) {
      where.dueDate = {};
      if (query.from) where.dueDate.gte = query.from;
      if (query.to) where.dueDate.lte = query.to;
    }

    if (query.search) {
      where.OR = [
        { title: { contains: query.search, mode: "insensitive" } },
        { description: { contains: query.search, mode: "insensitive" } },
      ];
    }

    const skip = (query.page - 1) * query.limit;
    const take = query.limit;

    const [bills, total] = await Promise.all([
      prisma.bill.findMany({
        where,
        skip,
        take,
        orderBy: { dueDate: "asc" },
      }),
      prisma.bill.count({ where }),
    ]);

    return {
      bills,
      pagination: {
        total,
        page: query.page,
        limit: query.limit,
        totalPages: Math.ceil(total / query.limit),
      },
    };
  }

  /**
   * Core "Attention" Dashboard aggregator.
   * Categorizes pending bills into:
   * - Overdue (< today)
   * - Due Soon (today to next 7 days)
   * - Upcoming (next 8 to 30 days)
   */
  async getDashboard(userId: string): Promise<DashboardData> {
    const now = new Date();
    // Midnight start of today (local UTC day boundary)
    const todayStart = new Date(
      Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()),
    );
    const in7Days = new Date(todayStart.getTime() + 7 * 24 * 60 * 60 * 1000);
    const in30Days = new Date(todayStart.getTime() + 30 * 24 * 60 * 60 * 1000);

    const pendingBills = await prisma.bill.findMany({
      where: {
        userId,
        status: "PENDING",
      },
      orderBy: { dueDate: "asc" },
    });

    const overdue: Bill[] = [];
    const dueSoon: Bill[] = [];
    const upcoming: Bill[] = [];

    let totalPendingAmount = 0;
    let preferredCurrency = "INR";

    for (const bill of pendingBills) {
      const dueTime = bill.dueDate.getTime();
      const amountNum = Number(bill.amount);
      totalPendingAmount += amountNum;
      preferredCurrency = bill.currency;

      if (dueTime < todayStart.getTime()) {
        overdue.push(bill);
      } else if (dueTime <= in7Days.getTime()) {
        dueSoon.push(bill);
      } else if (dueTime <= in30Days.getTime()) {
        upcoming.push(bill);
      }
    }

    return {
      overdue,
      dueSoon,
      upcoming,
      metrics: {
        totalPendingAmount: Math.round(totalPendingAmount * 100) / 100,
        overdueCount: overdue.length,
        dueSoonCount: dueSoon.length,
        upcomingCount: upcoming.length,
        currency: preferredCurrency,
      },
    };
  }

  /**
   * Retrieves a single bill by ID (verifying ownership).
   */
  async getBillById(userId: string, billId: string): Promise<Bill> {
    const bill = await prisma.bill.findUnique({
      where: { id: billId },
      include: {
        childBills: {
          select: {
            id: true,
            dueDate: true,
            status: true,
            amount: true,
            paidAt: true,
          },
          take: 5,
          orderBy: { dueDate: "desc" },
        },
      },
    });

    if (!bill || bill.userId !== userId) {
      const error = new Error("Bill not found");
      (error as any).status = 404;
      throw error;
    }

    return bill;
  }

  /**
   * Updates an existing bill.
   */
  async updateBill(
    userId: string,
    billId: string,
    input: UpdateBillInput,
  ): Promise<Bill> {
    // Verify ownership
    await this.getBillById(userId, billId);

    const data: Prisma.BillUpdateInput = {};

    if (input.title !== undefined) data.title = input.title;
    if (input.description !== undefined) data.description = input.description;
    if (input.category !== undefined) data.category = input.category;
    if (input.amount !== undefined)
      data.amount = new Prisma.Decimal(input.amount);
    if (input.currency !== undefined) data.currency = input.currency;
    if (input.dueDate !== undefined) data.dueDate = input.dueDate;
    if (input.status !== undefined) data.status = input.status;
    if (input.isRecurring !== undefined) {
      data.isRecurring = input.isRecurring;
      data.recurrenceInterval = input.isRecurring
        ? input.recurrenceInterval
        : null;
    }
    if (input.notes !== undefined) data.notes = input.notes;

    return prisma.bill.update({
      where: { id: billId },
      data,
    });
  }

  /**
   * Marks a bill as paid.
   * If the bill is recurring, automatically schedules the next occurrence linked to parentBillId.
   */
  async payBill(
    userId: string,
    billId: string,
    input: PayBillInput,
  ): Promise<{ paidBill: Bill; nextBill: Bill | null }> {
    const bill = await this.getBillById(userId, billId);

    if (bill.status === "PAID") {
      const error = new Error("Bill is already marked as paid");
      (error as any).status = 400;
      throw error;
    }

    const paidAt = input.paidAt || new Date();
    const paidAmount = input.paidAmount
      ? new Prisma.Decimal(input.paidAmount)
      : bill.amount;

    // Update current bill to PAID
    const paidBill = await prisma.bill.update({
      where: { id: billId },
      data: {
        status: "PAID",
        paidAt,
        paidAmount,
        paymentMethod: input.paymentMethod || null,
      },
    });

    let nextBill: Bill | null = null;

    // If recurring, schedule the next occurrence immediately
    if (bill.isRecurring && bill.recurrenceInterval) {
      const nextDueDate = this.calculateNextDueDate(
        bill.dueDate,
        bill.recurrenceInterval,
      );
      const parentBillId = bill.parentBillId || bill.id;

      nextBill = await prisma.bill.create({
        data: {
          userId,
          title: bill.title,
          description: bill.description,
          category: bill.category,
          amount: bill.amount,
          currency: bill.currency,
          dueDate: nextDueDate,
          status: "PENDING",
          isRecurring: true,
          recurrenceInterval: bill.recurrenceInterval,
          parentBillId,
          notes: bill.notes,
        },
      });
    }

    return {
      paidBill,
      nextBill,
    };
  }

  /**
   * Deletes a bill and cleans up associated Cloudinary assets.
   */
  async deleteBill(userId: string, billId: string): Promise<void> {
    const bill = await this.getBillById(userId, billId);

    // Clean up attached invoice if present
    if (bill.billUrl) {
      const publicId = extractPublicIdFromUrl(bill.billUrl);
      if (publicId) {
        try {
          await cloudinaryService.deleteImage(publicId);
        } catch (err) {
          console.warn("Failed to delete bill invoice from Cloudinary:", err);
        }
      }
    }

    // Clean up attached receipt if present
    if (bill.receiptUrl) {
      const publicId = extractPublicIdFromUrl(bill.receiptUrl);
      if (publicId) {
        try {
          await cloudinaryService.deleteImage(publicId);
        } catch (err) {
          console.warn("Failed to delete bill receipt from Cloudinary:", err);
        }
      }
    }

    await prisma.bill.delete({
      where: { id: billId },
    });
  }

  /**
   * Uploads an invoice or receipt attachment to Cloudinary under the user-partitioned folder.
   */
  async uploadAttachment(
    userId: string,
    billId: string,
    file: Express.Multer.File,
    type: "invoice" | "receipt",
  ): Promise<{ bill: Bill; attachmentUrl: string }> {
    const bill = await this.getBillById(userId, billId);

    const folder = `kin/users/${userId}/bills/${type}s`;
    const publicId = `bill_${billId}_${type}_${Date.now()}`;

    // Upload new image to Cloudinary
    const uploadResult = await cloudinaryService.uploadImage(file, {
      folder,
      publicId,
    });

    // Delete old attachment if replacing
    const oldUrl = type === "invoice" ? bill.billUrl : bill.receiptUrl;
    if (oldUrl) {
      const oldPublicId = extractPublicIdFromUrl(oldUrl);
      if (oldPublicId) {
        try {
          await cloudinaryService.deleteImage(oldPublicId);
        } catch (err) {
          console.warn("Failed to delete old attachment from Cloudinary:", err);
        }
      }
    }

    // Update bill in database
    const updatedBill = await prisma.bill.update({
      where: { id: billId },
      data: {
        [type === "invoice" ? "billUrl" : "receiptUrl"]: uploadResult.secureUrl,
      },
    });

    return {
      bill: updatedBill,
      attachmentUrl: uploadResult.secureUrl,
    };
  }
}

export const billsService = new BillsService();
