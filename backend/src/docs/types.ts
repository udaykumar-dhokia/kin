export type HttpMethod = "GET" | "POST" | "PUT" | "PATCH" | "DELETE";

export interface DocParameter {
  name: string;
  in: "path" | "query" | "header";
  required?: boolean;
  type?: "string" | "number" | "boolean";
  description: string;
  example?: string | number | boolean;
}

export interface DocRequestBody {
  description?: string;
  required?: boolean;
  contentType?: string;
  example: Record<string, any>;
  schema?: Record<string, any>;
}

export interface DocResponse {
  statusCode: number;
  description: string;
  example?: Record<string, any>;
}

export interface EndpointDoc {
  name: string;
  description: string;
  method: HttpMethod;
  path: string; // e.g. "/api/v1/bills/:id"
  requiresAuth?: boolean;
  parameters?: DocParameter[];
  requestBody?: DocRequestBody;
  responses: DocResponse[];
  postmanTests?: string[];
  postmanPrerequest?: string[];
}

export interface FeatureDoc {
  name: string;
  description: string;
  endpoints: EndpointDoc[];
}
