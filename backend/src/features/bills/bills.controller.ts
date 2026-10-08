import type { Request, Response } from "express";
import status from "http-status";
import { ZodError } from "zod";
import { billsService } from "./bills.service";
import {
  createBillSchema,
  updateBillSchema,
  payBillSchema,
  queryBillsSchema,
  uploadAttachmentSchema,
} from "./bills.validation";

export class BillsController {
  /**
   * Create a new bill.
   */
  async createBill(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.id;
      const validatedInput = createBillSchema.parse(req.body);
      const bill = await billsService.createBill(userId, validatedInput);

      res.status(status.CREATED).json({
        message: "Bill created successfully",
        bill,
      });
    } catch (error: any) {
      this.handleError(res, error, "Failed to create bill");
    }
  }

  /**
   * List bills with filters and pagination.
   */
  async getBills(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.id;
      const query = queryBillsSchema.parse(req.query);
      const result = await billsService.getBills(userId, query);

      res.status(status.OK).json(result);
    } catch (error: any) {
      this.handleError(res, error, "Failed to retrieve bills");
    }
  }

  /**
   * Core Attention Dashboard endpoint.
   */
  async getDashboard(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.id;
      const dashboard = await billsService.getDashboard(userId);

      res.status(status.OK).json({
        dashboard,
      });
    } catch (error: any) {
      this.handleError(res, error, "Failed to retrieve dashboard");
    }
  }

  /**
   * Get single bill details.
   */
  async getBillById(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.id;
      const bill = await billsService.getBillById(
        userId,
        req.params.id as string,
      );

      res.status(status.OK).json({ bill });
    } catch (error: any) {
      this.handleError(res, error, "Failed to retrieve bill");
    }
  }

  /**
   * Update a bill.
   */
  async updateBill(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.id;
      const validatedInput = updateBillSchema.parse(req.body);
      const bill = await billsService.updateBill(
        userId,
        req.params.id as string,
        validatedInput,
      );

      res.status(status.OK).json({
        message: "Bill updated successfully",
        bill,
      });
    } catch (error: any) {
      this.handleError(res, error, "Failed to update bill");
    }
  }

  /**
   * Mark a bill as paid.
   */
  async payBill(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.id;
      const validatedInput = payBillSchema.parse(req.body);
      const result = await billsService.payBill(
        userId,
        req.params.id as string,
        validatedInput,
      );

      res.status(status.OK).json({
        message: "Bill marked as paid successfully",
        paidBill: result.paidBill,
        nextBill: result.nextBill,
      });
    } catch (error: any) {
      this.handleError(res, error, "Failed to mark bill as paid");
    }
  }

  /**
   * Delete a bill and clean up attachments.
   */
  async deleteBill(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.id;
      await billsService.deleteBill(userId, req.params.id as string);

      res.status(status.OK).json({
        message: "Bill deleted successfully",
      });
    } catch (error: any) {
      this.handleError(res, error, "Failed to delete bill");
    }
  }

  /**
   * Upload bill invoice or payment receipt attachment.
   */
  async uploadAttachment(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.id;

      if (!req.file) {
        res.status(status.BAD_REQUEST).json({
          message: "No image file uploaded",
        });
        return;
      }

      // Attachment type can come from body or query param
      const rawType = req.body?.type || req.query?.type;
      const { type } = uploadAttachmentSchema.parse({ type: rawType });

      const result = await billsService.uploadAttachment(
        userId,
        req.params.id as string,
        req.file,
        type,
      );

      res.status(status.OK).json({
        message: `${type === "invoice" ? "Invoice" : "Receipt"} uploaded successfully`,
        bill: result.bill,
        attachmentUrl: result.attachmentUrl,
      });
    } catch (error: any) {
      this.handleError(res, error, "Failed to upload attachment");
    }
  }

  private handleError(res: Response, error: any, defaultMessage: string): void {
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
      message: error.message || defaultMessage,
    });
  }
}

export const billsController = new BillsController();
