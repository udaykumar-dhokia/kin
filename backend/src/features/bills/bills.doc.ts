import type { FeatureDoc } from "../../docs/types";

export const billsDoc: FeatureDoc = {
  name: "Bills & Payments",
  description:
    "Financial responsibilities, attention dashboard, recurrence scheduling, and attachments",
  endpoints: [
    {
      name: "Get Attention Dashboard",
      description:
        "Returns categorized urgent items (Overdue, Due Soon in 7 days, Upcoming in 30 days) and financial totals.",
      method: "GET",
      path: "/api/v1/bills/dashboard",
      requiresAuth: true,
      responses: [
        {
          statusCode: 200,
          description: "Dashboard attention view",
          example: {
            dashboard: {
              overdue: [],
              dueSoon: [],
              upcoming: [],
              metrics: {
                totalPendingAmount: 22000,
                overdueCount: 0,
                dueSoonCount: 0,
                upcomingCount: 1,
                currency: "INR",
              },
            },
          },
        },
      ],
      postmanTests: [
        `pm.test("Status code is 200 OK", function () {
    pm.response.to.have.status(200);
});
const response = pm.response.json();
pm.test("Dashboard contains attention categories", function () {
    pm.expect(response.dashboard).to.be.an("object");
    pm.expect(response.dashboard.overdue).to.be.an("array");
    pm.expect(response.dashboard.dueSoon).to.be.an("array");
    pm.expect(response.dashboard.upcoming).to.be.an("array");
    pm.expect(response.dashboard.metrics).to.be.an("object");
});`,
      ],
    },
    {
      name: "Create Bill",
      description:
        "Manually creates a new bill or recurring financial responsibility.",
      method: "POST",
      path: "/api/v1/bills",
      requiresAuth: true,
      requestBody: {
        description: "New bill data",
        required: true,
        example: {
          title: "Apartment Rent",
          description: "Monthly apartment rent payment to landlord",
          category: "RENT",
          amount: 22000,
          currency: "INR",
          dueDate: "2026-11-01T00:00:00.000Z",
          isRecurring: true,
          recurrenceInterval: "MONTHLY",
          notes: "Landlord bank transfer",
        },
      },
      responses: [
        {
          statusCode: 201,
          description: "Bill created successfully",
          example: {
            message: "Bill created successfully",
            bill: {
              id: "b1a2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d",
              userId: "3fa85f64-5717-4562-b3fc-2c963f66afa6",
              title: "Apartment Rent",
              category: "RENT",
              amount: "22000.00",
              currency: "INR",
              dueDate: "2026-11-01T00:00:00.000Z",
              status: "PENDING",
              isRecurring: true,
              recurrenceInterval: "MONTHLY",
            },
          },
        },
      ],
      postmanTests: [
        `pm.test("Status code is 201 Created", function () {
    pm.response.to.have.status(201);
});
const response = pm.response.json();
if (response.bill && response.bill.id) {
    pm.collectionVariables.set("createdBillId", response.bill.id);
    console.log("Saved createdBillId:", response.bill.id);
}`,
      ],
    },
    {
      name: "List Bills",
      description:
        "Retrieves a paginated list of bills with optional filters for status, category, date range, or search.",
      method: "GET",
      path: "/api/v1/bills",
      requiresAuth: true,
      parameters: [
        {
          name: "status",
          in: "query",
          description: "Filter by status (PENDING, PAID, OVERDUE, CANCELLED)",
          example: "PENDING",
        },
        {
          name: "category",
          in: "query",
          description: "Filter by category (RENT, ELECTRICITY, etc.)",
          example: "RENT",
        },
        {
          name: "page",
          in: "query",
          description: "Page number",
          example: 1,
        },
        {
          name: "limit",
          in: "query",
          description: "Results per page (max 100)",
          example: 20,
        },
      ],
      responses: [
        {
          statusCode: 200,
          description: "List of bills and pagination metadata",
          example: {
            bills: [],
            pagination: {
              total: 1,
              page: 1,
              limit: 20,
              totalPages: 1,
            },
          },
        },
      ],
      postmanTests: [
        `pm.test("Status code is 200 OK", function () {
    pm.response.to.have.status(200);
});
const response = pm.response.json();
pm.test("Bills list and pagination returned", function () {
    pm.expect(response.bills).to.be.an("array");
    pm.expect(response.pagination).to.be.an("object");
});`,
      ],
    },
    {
      name: "Get Bill By ID",
      description:
        "Retrieves details for a single bill including recurrence cycle history.",
      method: "GET",
      path: "/api/v1/bills/{{createdBillId}}",
      requiresAuth: true,
      parameters: [
        {
          name: "id",
          in: "path",
          required: true,
          description: "Bill UUID",
          example: "{{createdBillId}}",
        },
      ],
      responses: [
        {
          statusCode: 200,
          description: "Single bill details",
        },
        {
          statusCode: 404,
          description: "Bill not found",
        },
      ],
      postmanTests: [
        `pm.test("Status code is 200 OK", function () {
    pm.response.to.have.status(200);
});
const response = pm.response.json();
pm.test("Bill data returned", function () {
    pm.expect(response.bill).to.be.an("object");
});`,
      ],
    },
    {
      name: "Update Bill",
      description: "Updates details of an existing bill.",
      method: "PATCH",
      path: "/api/v1/bills/{{createdBillId}}",
      requiresAuth: true,
      parameters: [
        {
          name: "id",
          in: "path",
          required: true,
          description: "Bill UUID",
          example: "{{createdBillId}}",
        },
      ],
      requestBody: {
        description: "Fields to update",
        required: true,
        example: {
          notes: "Updated note: landlord requested transfer via HDFC",
          amount: 22500,
        },
      },
      responses: [
        {
          statusCode: 200,
          description: "Bill updated successfully",
        },
      ],
      postmanTests: [
        `pm.test("Status code is 200 OK", function () {
    pm.response.to.have.status(200);
});`,
      ],
    },
    {
      name: "Mark Bill as Paid",
      description:
        "Marks a bill as paid. If recurring, automatically generates the next cycle's bill.",
      method: "POST",
      path: "/api/v1/bills/{{createdBillId}}/pay",
      requiresAuth: true,
      parameters: [
        {
          name: "id",
          in: "path",
          required: true,
          description: "Bill UUID",
          example: "{{createdBillId}}",
        },
      ],
      requestBody: {
        description: "Payment details",
        required: false,
        example: {
          paymentMethod: "UPI",
          paidAmount: 22000,
        },
      },
      responses: [
        {
          statusCode: 200,
          description: "Bill paid and next cycle scheduled",
          example: {
            message: "Bill marked as paid successfully",
            paidBill: {
              status: "PAID",
              paidAmount: "22000.00",
              paymentMethod: "UPI",
            },
            nextBill: {
              status: "PENDING",
              dueDate: "2026-12-01T00:00:00.000Z",
            },
          },
        },
      ],
      postmanTests: [
        `pm.test("Status code is 200 OK", function () {
    pm.response.to.have.status(200);
});
const response = pm.response.json();
pm.test("Bill marked as PAID", function () {
    pm.expect(response.paidBill.status).to.equal("PAID");
});`,
      ],
    },
    {
      name: "Delete Bill",
      description:
        "Deletes a bill and removes any attached Cloudinary invoice/receipt files.",
      method: "DELETE",
      path: "/api/v1/bills/{{createdBillId}}",
      requiresAuth: true,
      parameters: [
        {
          name: "id",
          in: "path",
          required: true,
          description: "Bill UUID",
          example: "{{createdBillId}}",
        },
      ],
      responses: [
        {
          statusCode: 200,
          description: "Bill deleted successfully",
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
