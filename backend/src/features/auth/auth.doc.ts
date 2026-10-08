import type { FeatureDoc } from "../../docs/types";

export const authDoc: FeatureDoc = {
  name: "Authentication",
  description:
    "User registration, Argon2id authentication, session lifecycle, and token management",
  endpoints: [
    {
      name: "Register User",
      description:
        "Registers a new user with Argon2id password hashing, creates an active session, and returns tokens.",
      method: "POST",
      path: "/api/v1/auth/register",
      requiresAuth: false,
      requestBody: {
        description: "User registration details",
        required: true,
        example: {
          email: "user@example.com",
          password: "StrongPassword123!",
          firstName: "Alex",
          lastName: "Kumar",
        },
      },
      responses: [
        {
          statusCode: 201,
          description: "User registered successfully",
          example: {
            message: "User registered successfully",
            user: {
              id: "3fa85f64-5717-4562-b3fc-2c963f66afa6",
              email: "user@example.com",
              firstName: "Alex",
              lastName: "Kumar",
              avatarUrl: null,
              emailVerified: false,
            },
            accessToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
            refreshToken: "c79f8263e8a4a...",
          },
        },
        {
          statusCode: 400,
          description: "Validation failed",
        },
        {
          statusCode: 409,
          description: "User with this email already exists",
        },
      ],
      postmanTests: [
        `pm.test("Status code is 201 Created", function () {
    pm.response.to.have.status(201);
});
const response = pm.response.json();
if (response.accessToken) {
    pm.collectionVariables.set("accessToken", response.accessToken);
    console.log("Collection variable 'accessToken' updated.");
}`,
      ],
    },
    {
      name: "Login User",
      description:
        "Authenticates credentials using Argon2id, generates a new session, and returns tokens.",
      method: "POST",
      path: "/api/v1/auth/login",
      requiresAuth: false,
      requestBody: {
        description: "User login credentials",
        required: true,
        example: {
          email: "user@example.com",
          password: "StrongPassword123!",
        },
      },
      responses: [
        {
          statusCode: 200,
          description: "Login successful",
          example: {
            message: "Login successful",
            user: {
              id: "3fa85f64-5717-4562-b3fc-2c963f66afa6",
              email: "user@example.com",
              firstName: "Alex",
              lastName: "Kumar",
            },
            accessToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
            refreshToken: "c79f8263e8a4a...",
          },
        },
        {
          statusCode: 401,
          description: "Invalid email or password",
        },
      ],
      postmanTests: [
        `pm.test("Status code is 200 OK", function () {
    pm.response.to.have.status(200);
});
const response = pm.response.json();
if (response.accessToken) {
    pm.collectionVariables.set("accessToken", response.accessToken);
    console.log("Collection variable 'accessToken' updated.");
}`,
      ],
    },
    {
      name: "Refresh Token",
      description:
        "Rotates refresh token and issues a new access token. Reads from cookie or JSON body.",
      method: "POST",
      path: "/api/v1/auth/refresh",
      requiresAuth: false,
      requestBody: {
        description: "Optional refresh token in body if not using cookies",
        required: false,
        example: {
          refreshToken: "optional_refresh_token_if_not_in_cookie",
        },
      },
      responses: [
        {
          statusCode: 200,
          description: "Token refreshed successfully",
          example: {
            message: "Token refreshed successfully",
            accessToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
            refreshToken: "new_rotated_refresh_token...",
          },
        },
        {
          statusCode: 401,
          description: "Invalid or expired session",
        },
      ],
      postmanTests: [
        `pm.test("Status code is 200 OK", function () {
    pm.response.to.have.status(200);
});
const response = pm.response.json();
if (response.accessToken) {
    pm.collectionVariables.set("accessToken", response.accessToken);
}`,
      ],
    },
    {
      name: "Get Current Profile",
      description: "Returns profile details for the authenticated user.",
      method: "GET",
      path: "/api/v1/auth/me",
      requiresAuth: true,
      responses: [
        {
          statusCode: 200,
          description: "User profile details",
          example: {
            user: {
              id: "3fa85f64-5717-4562-b3fc-2c963f66afa6",
              email: "user@example.com",
              firstName: "Alex",
              lastName: "Kumar",
              avatarUrl: null,
              emailVerified: false,
            },
          },
        },
        {
          statusCode: 401,
          description: "Unauthorized",
        },
      ],
      postmanTests: [
        `pm.test("Status code is 200 OK", function () {
    pm.response.to.have.status(200);
});
const response = pm.response.json();
pm.test("User object returned", function () {
    pm.expect(response.user).to.be.an("object");
    pm.expect(response.user.email).to.be.a("string");
});`,
      ],
    },
    {
      name: "Logout",
      description:
        "Revokes the active session and clears the refresh token cookie.",
      method: "POST",
      path: "/api/v1/auth/logout",
      requiresAuth: true,
      responses: [
        {
          statusCode: 200,
          description: "Logged out successfully",
          example: {
            message: "Logged out successfully",
          },
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
