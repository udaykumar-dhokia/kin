import crypto from "crypto";
import { prisma } from "../../config/prismaClient";
import type {
  Household,
  HouseholdMember,
  HouseholdInvitation,
  Bill,
} from "../../../generated/prisma/client";
import {
  cloudinaryService,
  extractPublicIdFromUrl,
} from "../../utils/cloudinary.util";
import type {
  CreateMemberInput,
  UpdateMemberInput,
  UpdateHouseholdInput,
  CreateInvitationInput,
} from "./family.validation";

export interface HouseholdWithDetails extends Household {
  members: (HouseholdMember & {
    user: {
      id: string;
      email: string;
      firstName: string;
      lastName: string | null;
      avatarUrl: string | null;
    } | null;
  })[];
  invitations: HouseholdInvitation[];
}

export class FamilyService {
  /**
   * Retrieves or automatically provisions the user's primary household.
   */
  async getOrCreatePrimaryHousehold(
    userId: string,
  ): Promise<HouseholdWithDetails> {
    // 1. Check if user is a member of an existing household
    let membership = await prisma.householdMember.findFirst({
      where: { userId },
      include: {
        household: {
          include: {
            members: {
              include: {
                user: {
                  select: {
                    id: true,
                    email: true,
                    firstName: true,
                    lastName: true,
                    avatarUrl: true,
                  },
                },
              },
              orderBy: { createdAt: "asc" },
            },
            invitations: {
              where: { status: "PENDING" },
              orderBy: { createdAt: "desc" },
            },
          },
        },
      },
    });

    if (membership?.household) {
      return membership.household as unknown as HouseholdWithDetails;
    }

    // 2. Check if user owns a household
    let owned = await prisma.household.findFirst({
      where: { ownerId: userId },
      include: {
        members: {
          include: {
            user: {
              select: {
                id: true,
                email: true,
                firstName: true,
                lastName: true,
                avatarUrl: true,
              },
            },
          },
          orderBy: { createdAt: "asc" },
        },
        invitations: {
          where: { status: "PENDING" },
          orderBy: { createdAt: "desc" },
        },
      },
    });

    if (owned) {
      // Ensure owner has a SELF member record
      const hasSelfMember = owned.members.some((m) => m.userId === userId);
      if (!hasSelfMember) {
        const user = await prisma.user.findUnique({ where: { id: userId } });
        if (user) {
          await prisma.householdMember.create({
            data: {
              householdId: owned.id,
              userId: user.id,
              name: `${user.firstName} ${user.lastName || ""}`.trim(),
              relationship: "SELF",
              role: "OWNER",
              avatarUrl: user.avatarUrl,
            },
          });
        }
      }
      return owned as unknown as HouseholdWithDetails;
    }

    // 3. Auto-provision new primary household
    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user) {
      const error = new Error("User account not found");
      (error as any).status = 404;
      throw error;
    }

    const householdName = `${user.firstName}'s Family`;

    const newHousehold = await prisma.household.create({
      data: {
        name: householdName,
        ownerId: user.id,
        currency: "INR",
        members: {
          create: {
            userId: user.id,
            name: `${user.firstName} ${user.lastName || ""}`.trim(),
            relationship: "SELF",
            role: "OWNER",
            avatarUrl: user.avatarUrl,
          },
        },
      },
      include: {
        members: {
          include: {
            user: {
              select: {
                id: true,
                email: true,
                firstName: true,
                lastName: true,
                avatarUrl: true,
              },
            },
          },
        },
        invitations: true,
      },
    });

    return newHousehold as unknown as HouseholdWithDetails;
  }

  /**
   * Retrieves the user's primary household.
   */
  async getHousehold(userId: string): Promise<HouseholdWithDetails> {
    return this.getOrCreatePrimaryHousehold(userId);
  }

  /**
   * Updates household settings (name, currency).
   */
  async updateHousehold(
    userId: string,
    input: UpdateHouseholdInput,
  ): Promise<Household> {
    const household = await this.getOrCreatePrimaryHousehold(userId);
    this.assertIsAdminOrOwner(household, userId);

    return prisma.household.update({
      where: { id: household.id },
      data: {
        name: input.name,
        currency: input.currency,
      },
    });
  }

  /**
   * Adds a managed dependent family member (child, parent, pet) with no login required.
   */
  async addMember(
    userId: string,
    input: CreateMemberInput,
  ): Promise<HouseholdMember> {
    const household = await this.getOrCreatePrimaryHousehold(userId);
    this.assertIsAdminOrOwner(household, userId);

    return prisma.householdMember.create({
      data: {
        householdId: household.id,
        userId: null, // Managed profile
        name: input.name,
        relationship: input.relationship,
        role: input.role,
        dateOfBirth: input.dateOfBirth,
        color: input.color,
        notes: input.notes,
      },
    });
  }

  /**
   * Retrieves single member details.
   */
  async getMemberById(
    userId: string,
    memberId: string,
  ): Promise<
    HouseholdMember & {
      assignedBills: Bill[];
    }
  > {
    const household = await this.getOrCreatePrimaryHousehold(userId);

    const member = await prisma.householdMember.findUnique({
      where: { id: memberId },
      include: {
        assignedBills: {
          orderBy: { dueDate: "asc" },
        },
      },
    });

    if (!member || member.householdId !== household.id) {
      const error = new Error("Family member not found in your household");
      (error as any).status = 404;
      throw error;
    }

    return member;
  }

  /**
   * Updates an existing family member profile.
   */
  async updateMember(
    userId: string,
    memberId: string,
    input: UpdateMemberInput,
  ): Promise<HouseholdMember> {
    const household = await this.getOrCreatePrimaryHousehold(userId);
    this.assertIsAdminOrOwner(household, userId);

    const member = await prisma.householdMember.findUnique({
      where: { id: memberId },
    });

    if (!member || member.householdId !== household.id) {
      const error = new Error("Family member not found in your household");
      (error as any).status = 404;
      throw error;
    }

    return prisma.householdMember.update({
      where: { id: memberId },
      data: {
        name: input.name,
        relationship: input.relationship,
        role: input.role,
        dateOfBirth: input.dateOfBirth,
        color: input.color,
        notes: input.notes,
      },
    });
  }

  /**
   * Removes a family member from the household.
   * Gracefully unassigns any linked bills (sets assignedMemberId: null).
   */
  async removeMember(userId: string, memberId: string): Promise<void> {
    const household = await this.getOrCreatePrimaryHousehold(userId);
    this.assertIsAdminOrOwner(household, userId);

    const member = await prisma.householdMember.findUnique({
      where: { id: memberId },
    });

    if (!member || member.householdId !== household.id) {
      const error = new Error("Family member not found in your household");
      (error as any).status = 404;
      throw error;
    }

    // Protect household owner
    if (member.userId === household.ownerId) {
      const error = new Error("The household owner profile cannot be removed");
      (error as any).status = 400;
      throw error;
    }

    // Delete avatar from Cloudinary if present
    if (member.avatarUrl) {
      const publicId = extractPublicIdFromUrl(member.avatarUrl);
      if (publicId) {
        try {
          await cloudinaryService.deleteImage(publicId);
        } catch (err) {
          console.warn("Failed to delete member avatar from Cloudinary:", err);
        }
      }
    }

    // Safely unassign all bills linked to this member
    await prisma.bill.updateMany({
      where: { assignedMemberId: memberId },
      data: { assignedMemberId: null },
    });

    // Delete member record
    await prisma.householdMember.delete({
      where: { id: memberId },
    });
  }

  /**
   * Uploads or updates an avatar for a family member via Cloudinary.
   */
  async uploadMemberAvatar(
    userId: string,
    memberId: string,
    file: Express.Multer.File,
  ): Promise<{ member: HouseholdMember; avatarUrl: string }> {
    const household = await this.getOrCreatePrimaryHousehold(userId);

    const member = await prisma.householdMember.findUnique({
      where: { id: memberId },
    });

    if (!member || member.householdId !== household.id) {
      const error = new Error("Family member not found in your household");
      (error as any).status = 404;
      throw error;
    }

    const folder = `kin/users/${household.ownerId}/family/${memberId}`;
    const publicId = `avatar_${Date.now()}`;

    const uploadResult = await cloudinaryService.uploadImage(file, {
      folder,
      publicId,
      transformation: {
        width: 400,
        height: 400,
        crop: "fill",
        gravity: "face",
      },
    });

    // Delete old avatar if present
    if (member.avatarUrl) {
      const oldPublicId = extractPublicIdFromUrl(member.avatarUrl);
      if (oldPublicId) {
        try {
          await cloudinaryService.deleteImage(oldPublicId);
        } catch (err) {
          console.warn("Failed to delete old avatar from Cloudinary:", err);
        }
      }
    }

    const updated = await prisma.householdMember.update({
      where: { id: memberId },
      data: { avatarUrl: uploadResult.secureUrl },
    });

    return {
      member: updated,
      avatarUrl: uploadResult.secureUrl,
    };
  }

  /**
   * Creates an invitation for an adult member (e.g. spouse) with a secure token.
   */
  async inviteMember(
    userId: string,
    input: CreateInvitationInput,
  ): Promise<{ invitation: HouseholdInvitation; inviteToken: string }> {
    const household = await this.getOrCreatePrimaryHousehold(userId);
    this.assertIsAdminOrOwner(household, userId);

    // Check if user is already in the household
    const existingMember = household.members.find(
      (m) => m.user?.email === input.email,
    );
    if (existingMember) {
      const error = new Error(
        "This user is already a member of your household",
      );
      (error as any).status = 409;
      throw error;
    }

    const token = crypto.randomBytes(32).toString("hex");
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7); // 7-day expiration

    // Invalidate prior pending invitations to the same email for this household
    await prisma.householdInvitation.updateMany({
      where: {
        householdId: household.id,
        email: input.email,
        status: "PENDING",
      },
      data: { status: "CANCELLED" },
    });

    const invitation = await prisma.householdInvitation.create({
      data: {
        householdId: household.id,
        invitedById: userId,
        email: input.email,
        name: input.name,
        relationship: input.relationship,
        role: input.role,
        token,
        status: "PENDING",
        expiresAt,
      },
    });

    return {
      invitation,
      inviteToken: token,
    };
  }

  /**
   * Accepts a household invitation using a valid token and joins the household.
   */
  async acceptInvitation(
    userId: string,
    token: string,
  ): Promise<{ household: Household; member: HouseholdMember }> {
    const invitation = await prisma.householdInvitation.findUnique({
      where: { token },
      include: { household: true },
    });

    if (
      !invitation ||
      invitation.status !== "PENDING" ||
      invitation.expiresAt < new Date()
    ) {
      const error = new Error("Invalid or expired invitation token");
      (error as any).status = 400;
      throw error;
    }

    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user) {
      const error = new Error("User not found");
      (error as any).status = 404;
      throw error;
    }

    // Check if user is already a member
    let member = await prisma.householdMember.findUnique({
      where: {
        householdId_userId: {
          householdId: invitation.householdId,
          userId: user.id,
        },
      },
    });

    if (!member) {
      member = await prisma.householdMember.create({
        data: {
          householdId: invitation.householdId,
          userId: user.id,
          name:
            `${user.firstName} ${user.lastName || ""}`.trim() ||
            invitation.name,
          relationship: invitation.relationship,
          role: invitation.role,
          avatarUrl: user.avatarUrl,
        },
      });
    }

    // Mark invitation as accepted
    await prisma.householdInvitation.update({
      where: { id: invitation.id },
      data: { status: "ACCEPTED" },
    });

    return {
      household: invitation.household,
      member,
    };
  }

  /**
   * Cancels a pending invitation.
   */
  async cancelInvitation(userId: string, invitationId: string): Promise<void> {
    const household = await this.getOrCreatePrimaryHousehold(userId);
    this.assertIsAdminOrOwner(household, userId);

    await prisma.householdInvitation.updateMany({
      where: { id: invitationId, householdId: household.id, status: "PENDING" },
      data: { status: "CANCELLED" },
    });
  }

  /**
   * Retrieves all bills assigned to a specific family member.
   */
  async getMemberBills(userId: string, memberId: string): Promise<Bill[]> {
    await this.getMemberById(userId, memberId);

    return prisma.bill.findMany({
      where: { assignedMemberId: memberId },
      orderBy: { dueDate: "asc" },
    });
  }

  /**
   * Validates that the requesting user has OWNER or ADMIN rights in the household.
   */
  private assertIsAdminOrOwner(
    household: HouseholdWithDetails,
    userId: string,
  ): void {
    if (household.ownerId === userId) return;

    const userMember = household.members.find((m) => m.userId === userId);
    if (
      !userMember ||
      (userMember.role !== "OWNER" && userMember.role !== "ADMIN")
    ) {
      const error = new Error(
        "You do not have administrative permission in this household",
      );
      (error as any).status = 403;
      throw error;
    }
  }
}

export const familyService = new FamilyService();
