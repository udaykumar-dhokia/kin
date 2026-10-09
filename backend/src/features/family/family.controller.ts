import type { Request, Response } from "express";
import status from "http-status";
import { ZodError } from "zod";
import { familyService } from "./family.service";
import {
  createMemberSchema,
  updateMemberSchema,
  updateHouseholdSchema,
  createInvitationSchema,
  acceptInvitationSchema,
} from "./family.validation";

export class FamilyController {
  /**
   * Get user's primary household, members, and invitations.
   */
  async getHousehold(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.id;
      const household = await familyService.getHousehold(userId);

      res.status(status.OK).json({ household });
    } catch (error: any) {
      this.handleError(res, error, "Failed to retrieve household");
    }
  }

  /**
   * Update household details.
   */
  async updateHousehold(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.id;
      const input = updateHouseholdSchema.parse(req.body);
      const household = await familyService.updateHousehold(userId, input);

      res.status(status.OK).json({
        message: "Household updated successfully",
        household,
      });
    } catch (error: any) {
      this.handleError(res, error, "Failed to update household");
    }
  }

  /**
   * Add a managed dependent family member.
   */
  async addMember(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.id;
      const input = createMemberSchema.parse(req.body);
      const member = await familyService.addMember(userId, input);

      res.status(status.CREATED).json({
        message: "Family member added successfully",
        member,
      });
    } catch (error: any) {
      this.handleError(res, error, "Failed to add family member");
    }
  }

  /**
   * Get single family member details.
   */
  async getMemberById(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.id;
      const member = await familyService.getMemberById(
        userId,
        req.params.id as string,
      );

      res.status(status.OK).json({ member });
    } catch (error: any) {
      this.handleError(res, error, "Failed to retrieve family member");
    }
  }

  /**
   * Update a family member profile.
   */
  async updateMember(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.id;
      const input = updateMemberSchema.parse(req.body);
      const member = await familyService.updateMember(
        userId,
        req.params.id as string,
        input,
      );

      res.status(status.OK).json({
        message: "Family member updated successfully",
        member,
      });
    } catch (error: any) {
      this.handleError(res, error, "Failed to update family member");
    }
  }

  /**
   * Remove a family member.
   */
  async removeMember(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.id;
      await familyService.removeMember(userId, req.params.id as string);

      res.status(status.OK).json({
        message: "Family member removed successfully",
      });
    } catch (error: any) {
      this.handleError(res, error, "Failed to remove family member");
    }
  }

  /**
   * Upload or update member avatar.
   */
  async uploadMemberAvatar(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.id;
      if (!req.file) {
        res.status(status.BAD_REQUEST).json({
          message: "No avatar image provided",
        });
        return;
      }

      const result = await familyService.uploadMemberAvatar(
        userId,
        req.params.id as string,
        req.file,
      );

      res.status(status.OK).json({
        message: "Avatar uploaded successfully",
        member: result.member,
        avatarUrl: result.avatarUrl,
      });
    } catch (error: any) {
      this.handleError(res, error, "Failed to upload member avatar");
    }
  }

  /**
   * Invite an adult family member via email.
   */
  async inviteMember(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.id;
      const input = createInvitationSchema.parse(req.body);
      const result = await familyService.inviteMember(userId, input);

      res.status(status.CREATED).json({
        message: "Invitation created successfully",
        invitation: result.invitation,
        inviteToken: result.inviteToken,
      });
    } catch (error: any) {
      this.handleError(res, error, "Failed to invite family member");
    }
  }

  /**
   * Accept an invitation using token.
   */
  async acceptInvitation(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.id;
      const { token } = acceptInvitationSchema.parse(req.body);
      const result = await familyService.acceptInvitation(userId, token);

      res.status(status.OK).json({
        message: "Joined household successfully",
        household: result.household,
        member: result.member,
      });
    } catch (error: any) {
      this.handleError(res, error, "Failed to accept invitation");
    }
  }

  /**
   * Cancel a pending invitation.
   */
  async cancelInvitation(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.id;
      await familyService.cancelInvitation(userId, req.params.id as string);

      res.status(status.OK).json({
        message: "Invitation cancelled successfully",
      });
    } catch (error: any) {
      this.handleError(res, error, "Failed to cancel invitation");
    }
  }

  /**
   * Get all bills assigned to a specific family member.
   */
  async getMemberBills(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.id;
      const bills = await familyService.getMemberBills(
        userId,
        req.params.id as string,
      );

      res.status(status.OK).json({ bills });
    } catch (error: any) {
      this.handleError(res, error, "Failed to retrieve member bills");
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

export const familyController = new FamilyController();
