import express from "express";
import { apiReference } from "@scalar/express-api-reference";
import { generateOpenApiSpec } from "./openapi.generator";
import { generatePostmanCollection } from "./postman.generator";

const router = express.Router();

// Dynamic OpenAPI 3.0 specification JSON
router.get("/openapi.json", (_req, res) => {
  const spec = generateOpenApiSpec();
  res.setHeader("Content-Type", "application/json");
  res.json(spec);
});

// Dynamic Postman Collection v2.1.0 JSON (Import directly into Postman via URL or file download)
router.get("/postman.json", (req, res) => {
  const protocol = req.protocol;
  const host = req.get("host") || "localhost:3333";
  const baseUrl = `${protocol}://${host}`;

  const collection = generatePostmanCollection({ baseUrl });
  res.setHeader("Content-Type", "application/json");
  res.setHeader(
    "Content-Disposition",
    'attachment; filename="kin.postman_collection.json"',
  );
  res.json(collection);
});

// Interactive in-browser documentation powered by Scalar
router.use("/", (req, res, next) => {
  const spec = generateOpenApiSpec();
  const handler = apiReference({
    pageTitle: "Kin - API Reference",
    url: "/docs/openapi.json",
    spec: {
      content: spec,
    },
  });
  return handler(req as any, res as any, next);
});

export default router;
