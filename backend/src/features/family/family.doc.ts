import type { FeatureDoc } from "../../docs/types";

export const familyDoc: FeatureDoc = {
  name: "Family & Household",
  description:
    "Life Admin OS multi-member household management, managed dependent profiles (children, parents), viral invitations, and member responsibilities",
  endpoints: [
    {
      name: "Get Primary Household",
      description:
        "Retrieves the user's primary household, all member profiles, and active pending invitations. Auto-provisions a default household if none exists.",
      method: "GET",
      path: "/api/v1/family",
      requiresAuth: true,
      responses: [
        {
          statusCode: 200,
          description: "Household details with members and invitations",
          example: {
            household: {
              id: "h1a2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d",
              name: "The Kumar Family",
              currency: "INR",
              ownerId: "3fa85f64-5717-4562-b3fc-2c963f66afa6",
              members: [
                {
                  id: "m1a2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d",
                  name: "Alex Kumar",
                  relationship: "SELF",
                  role: "OWNER",
                },
              ],
              invitations: [],
            },
          },
        },
      ],
      postmanTests: [
        `pm.test("Status code is 200 OK", function () {
    pm.response.to.have.status(200);
});
const response = pm.response.json();
pm.test("Household returned with members array", function () {
    pm.expect(response.household).to.be.an("object");
    pm.expect(response.household.members).to.be.an("array");
});`,
      ],
    },
    {
      name: "Update Household",
      description: "Updates household name or default currency settings.",
      method: "PATCH",
      path: "/api/v1/family",
      requiresAuth: true,
      requestBody: {
        description: "Fields to update",
        required: true,
        example: {
          name: "The Kumar Family Space",
          currency: "INR",
        },
      },
      responses: [
        {
          statusCode: 200,
          description: "Household updated successfully",
        },
      ],
      postmanTests: [
        `pm.test("Status code is 200 OK", function () {
    pm.response.to.have.status(200);
});`,
      ],
    },
    {
      name: "Add Family Member (Managed Dependent)",
      description:
        "Adds a managed family member (e.g., child or elderly parent) with no login required. This member can be assigned responsibilities and bills.",
      method: "POST",
      path: "/api/v1/family/members",
      requiresAuth: true,
      requestBody: {
        description: "Member profile data",
        required: true,
        example: {
          name: "Aarav Kumar",
          relationship: "SON",
          role: "MEMBER",
          dateOfBirth: "2018-05-12T00:00:00.000Z",
          color: "#10B981",
          notes: "Class 2 school fee due monthly",
        },
      },
      responses: [
        {
          statusCode: 201,
          description: "Member created successfully",
          example: {
            message: "Family member added successfully",
            member: {
              id: "m2a3c4d5-e6f7-8a9b-0c1d-2e3f4a5b6c7d",
              name: "Aarav Kumar",
              relationship: "SON",
              role: "MEMBER",
              color: "#10B981",
            },
          },
        },
      ],
      postmanTests: [
        `pm.test("Status code is 201 Created", function () {
    pm.response.to.have.status(201);
});
const response = pm.response.json();
if (response.member && response.member.id) {
    pm.collectionVariables.set("createdMemberId", response.member.id);
    console.log("Saved createdMemberId:", response.member.id);
}`,
      ],
    },
    {
      name: "Get Family Member by ID",
      description:
        "Retrieves details and assigned bills for a specific family member.",
      method: "GET",
      path: "/api/v1/family/members/{{createdMemberId}}",
      requiresAuth: true,
      parameters: [
        {
          name: "id",
          in: "path",
          required: true,
          description: "Member UUID",
          example: "{{createdMemberId}}",
        },
      ],
      responses: [
        {
          statusCode: 200,
          description: "Member profile details with assigned bills",
        },
      ],
      postmanTests: [
        `pm.test("Status code is 200 OK", function () {
    pm.response.to.have.status(200);
});
const response = pm.response.json();
pm.test("Member object returned", function () {
    pm.expect(response.member).to.be.an("object");
});`,
      ],
    },
    {
      name: "Update Family Member",
      description: "Updates a family member profile details.",
      method: "PATCH",
      path: "/api/v1/family/members/{{createdMemberId}}",
      requiresAuth: true,
      parameters: [
        {
          name: "id",
          in: "path",
          required: true,
          description: "Member UUID",
          example: "{{createdMemberId}}",
        },
      ],
      requestBody: {
        description: "Fields to update",
        required: true,
        example: {
          notes: "Updated school details: Greenwood High",
          color: "#3B82F6",
        },
      },
      responses: [
        {
          statusCode: 200,
          description: "Member updated successfully",
        },
      ],
      postmanTests: [
        `pm.test("Status code is 200 OK", function () {
    pm.response.to.have.status(200);
});`,
      ],
    },
    {
      name: "Get Member Assigned Bills",
      description:
        "Retrieves all bills and payment responsibilities assigned to this family member.",
      method: "GET",
      path: "/api/v1/family/members/{{createdMemberId}}",
      requiresAuth: true,
      parameters: [
        {
          name: "id",
          in: "path",
          required: true,
          description: "Member UUID",
          example: "{{createdMemberId}}",
        },
      ],
      responses: [
        {
          statusCode: 200,
          description: "List of bills for this member",
        },
      ],
      postmanTests: [
        `pm.test("Status code is 200 OK", function () {
    pm.response.to.have.status(200);
});`,
      ],
    },
    {
      name: "Invite Adult Family Member",
      description:
        "Sends an invitation for an adult family member (e.g. Spouse) with a secure token to collaborate in the household.",
      method: "POST",
      path: "/api/v1/family/invitations",
      requiresAuth: true,
      requestBody: {
        description: "Invitation details",
        required: true,
        example: {
          email: "spouse@example.com",
          name: "Priya Kumar",
          relationship: "SPOUSE",
          role: "ADMIN",
        },
      },
      responses: [
        {
          statusCode: 201,
          description: "Invitation created successfully",
          example: {
            message: "Invitation created successfully",
            inviteToken: "c87f9b23e...",
          },
        },
      ],
      postmanTests: [
        `pm.test("Status code is 201 Created", function () {
    pm.response.to.have.status(201);
});
const response = pm.response.json();
if (response.inviteToken) {
    pm.collectionVariables.set("inviteToken", response.inviteToken);
    console.log("Saved inviteToken:", response.inviteToken);
}
if (response.invitation && response.invitation.id) {
    pm.collectionVariables.set("invitationId", response.invitation.id);
}`,
      ],
    },
    {
      name: "Cancel Invitation",
      description: "Cancels or revokes a pending invitation.",
      method: "DELETE",
      path: "/api/v1/family/invitations/{{invitationId}}",
      requiresAuth: true,
      parameters: [
        {
          name: "id",
          in: "path",
          required: true,
          description: "Invitation UUID",
          example: "{{invitationId}}",
        },
      ],
      responses: [
        {
          statusCode: 200,
          description: "Invitation cancelled successfully",
        },
      ],
      postmanTests: [
        `pm.test("Status code is 200 OK", function () {
    pm.response.to.have.status(200);
});`,
      ],
    },
    {
      name: "Remove Family Member",
      description:
        "Removes a family member from the household and safely unassigns any linked bills without deleting the bills.",
      method: "DELETE",
      path: "/api/v1/family/members/{{createdMemberId}}",
      requiresAuth: true,
      parameters: [
        {
          name: "id",
          in: "path",
          required: true,
          description: "Member UUID",
          example: "{{createdMemberId}}",
        },
      ],
      responses: [
        {
          statusCode: 200,
          description: "Family member removed successfully",
        },
      ],
      postmanTests: [
        `pm.test("Status code is 200 OK", function () {
    pm.response.to.have.status(200);
});`,
      ],
    },
  ],
};
