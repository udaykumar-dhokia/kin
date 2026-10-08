import type { FeatureDoc, EndpointDoc } from "./types";
import { registeredFeatures } from "./docs.registry";

export interface GeneratePostmanOptions {
  name?: string;
  baseUrl?: string;
  features?: FeatureDoc[];
}

export function generatePostmanCollection(
  options: GeneratePostmanOptions = {},
): Record<string, any> {
  const collectionName = options.name || "Kin - Life Admin OS API";
  const baseUrl = options.baseUrl || "http://localhost:3333";
  const features = options.features || registeredFeatures;

  const folders = features.map((feature) => ({
    name: feature.name,
    description: feature.description,
    item: feature.endpoints.map((endpoint) =>
      buildPostmanRequestItem(endpoint),
    ),
  }));

  return {
    info: {
      name: collectionName,
      description:
        "Comprehensive API collection for Kin (Life Admin OS) with pre-configured requests, chained authentication tokens, and automated test assertions.",
      schema:
        "https://schema.getpostman.com/json/collection/v2.1.0/collection.json",
    },
    variable: [
      {
        key: "baseUrl",
        value: baseUrl,
        type: "string",
      },
      {
        key: "accessToken",
        value: "",
        type: "string",
      },
      {
        key: "createdBillId",
        value: "",
        type: "string",
      },
    ],
    item: folders,
  };
}

function buildPostmanRequestItem(endpoint: EndpointDoc): Record<string, any> {
  const headers: Array<{ key: string; value: string; type?: string }> = [];

  if (
    endpoint.requestBody &&
    endpoint.requestBody.contentType !== "multipart/form-data"
  ) {
    headers.push({
      key: "Content-Type",
      value: endpoint.requestBody.contentType || "application/json",
      type: "text",
    });
  }

  if (endpoint.requiresAuth) {
    headers.push({
      key: "Authorization",
      value: "Bearer {{accessToken}}",
      type: "text",
    });
  }

  // Parse path segments
  const pathParts = endpoint.path.replace(/^\/+/, "").split("/");

  // Query parameters
  const queryParams = (endpoint.parameters || [])
    .filter((p) => p.in === "query")
    .map((p) => ({
      key: p.name,
      value: p.example !== undefined ? String(p.example) : "",
      description: p.description,
    }));

  const urlObject: Record<string, any> = {
    raw: `{{baseUrl}}${endpoint.path}${
      queryParams.length > 0
        ? `?${queryParams.map((q) => `${q.key}=${q.value}`).join("&")}`
        : ""
    }`,
    host: ["{{baseUrl}}"],
    path: pathParts,
  };

  if (queryParams.length > 0) {
    urlObject.query = queryParams;
  }

  // Request Body
  let bodyObject: Record<string, any> | undefined;

  if (endpoint.requestBody && endpoint.requestBody.example) {
    if (endpoint.requestBody.contentType === "multipart/form-data") {
      bodyObject = {
        mode: "formdata",
        formdata: Object.entries(endpoint.requestBody.example).map(
          ([k, v]) => ({
            key: k,
            value: String(v),
            type: "text",
          }),
        ),
      };
    } else {
      bodyObject = {
        mode: "raw",
        raw: JSON.stringify(endpoint.requestBody.example, null, 2),
        options: {
          raw: {
            language: "json",
          },
        },
      };
    }
  }

  // Events (Test Scripts & Pre-request scripts)
  const events: Array<Record<string, any>> = [];

  if (endpoint.postmanPrerequest && endpoint.postmanPrerequest.length > 0) {
    events.push({
      listen: "prerequest",
      script: {
        type: "text/javascript",
        exec: endpoint.postmanPrerequest,
      },
    });
  }

  if (endpoint.postmanTests && endpoint.postmanTests.length > 0) {
    events.push({
      listen: "test",
      script: {
        type: "text/javascript",
        exec: endpoint.postmanTests,
      },
    });
  }

  return {
    name: endpoint.name,
    request: {
      method: endpoint.method,
      header: headers,
      url: urlObject,
      description: endpoint.description,
      body: bodyObject,
    },
    response: endpoint.responses.map((resp) => ({
      name: `${resp.statusCode} ${resp.description}`,
      status: String(resp.statusCode),
      code: resp.statusCode,
      body: resp.example ? JSON.stringify(resp.example, null, 2) : "",
      header: [{ key: "Content-Type", value: "application/json" }],
    })),
    event: events.length > 0 ? events : undefined,
  };
}
