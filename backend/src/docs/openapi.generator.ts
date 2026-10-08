import type { FeatureDoc } from "./types";
import { registeredFeatures } from "./docs.registry";

export interface GenerateOpenApiOptions {
  title?: string;
  version?: string;
  baseUrl?: string;
  features?: FeatureDoc[];
}

export function generateOpenApiSpec(
  options: GenerateOpenApiOptions = {},
): Record<string, any> {
  const title = options.title || "Kin - Life Admin OS API";
  const version = options.version || "1.0.0";
  const baseUrl = options.baseUrl || "http://localhost:3333";
  const features = options.features || registeredFeatures;

  const paths: Record<string, any> = {};

  for (const feature of features) {
    for (const endpoint of feature.endpoints) {
      // Normalize Express path parameters: :id -> {id}
      const openApiPath = endpoint.path.replace(/:([a-zA-Z0-9_]+)/g, "{$1}");

      if (!paths[openApiPath]) {
        paths[openApiPath] = {};
      }

      const methodKey = endpoint.method.toLowerCase();

      // Parameters
      const parameters = (endpoint.parameters || []).map((p) => ({
        name: p.name,
        in: p.in,
        required: p.required ?? p.in === "path",
        description: p.description,
        schema: {
          type: p.type || "string",
          example: p.example,
        },
      }));

      // Request Body
      let requestBody: Record<string, any> | undefined;
      if (endpoint.requestBody && endpoint.requestBody.example) {
        requestBody = {
          description: endpoint.requestBody.description,
          required: endpoint.requestBody.required ?? true,
          content: {
            [endpoint.requestBody.contentType || "application/json"]: {
              schema: {
                type: "object",
                example: endpoint.requestBody.example,
              },
            },
          },
        };
      }

      // Responses
      const responses: Record<string, any> = {};
      for (const resp of endpoint.responses) {
        responses[String(resp.statusCode)] = {
          description: resp.description,
          content: resp.example
            ? {
                "application/json": {
                  schema: {
                    type: "object",
                    example: resp.example,
                  },
                },
              }
            : undefined,
        };
      }

      paths[openApiPath][methodKey] = {
        summary: endpoint.name,
        description: endpoint.description,
        tags: [feature.name],
        parameters: parameters.length > 0 ? parameters : undefined,
        requestBody,
        responses,
        security: endpoint.requiresAuth ? [{ bearerAuth: [] }] : undefined,
      };
    }
  }

  return {
    openapi: "3.0.3",
    info: {
      title,
      version,
      description:
        "The personal operations system that remembers, organizes, and tracks life responsibilities, bills, renewals, and documents.",
    },
    servers: [
      {
        url: baseUrl,
        description: "Local development server",
      },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: "http",
          scheme: "bearer",
          bearerFormat: "JWT",
          description: "Enter your JWT access token",
        },
      },
    },
    paths,
  };
}
