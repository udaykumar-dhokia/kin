import fs from "fs";
import path from "path";
import { generatePostmanCollection } from "../docs/postman.generator";
import { generateOpenApiSpec } from "../docs/openapi.generator";
import { registeredFeatures } from "../docs/docs.registry";

console.log("=== Generating Kin API Documentation & Postman Collection ===");

const backendRoot = path.resolve(import.meta.dirname, "../..");
const postmanFilePath = path.join(backendRoot, "kin.postman_collection.json");
const openApiFilePath = path.join(backendRoot, "openapi.json");

// 1. Generate Postman Collection
const postmanCollection = generatePostmanCollection();
fs.writeFileSync(
  postmanFilePath,
  JSON.stringify(postmanCollection, null, 2),
  "utf-8",
);
console.log(`✔ Generated Postman Collection: ${postmanFilePath}`);

// 2. Generate OpenAPI 3.0 Specification
const openApiSpec = generateOpenApiSpec();
fs.writeFileSync(
  openApiFilePath,
  JSON.stringify(openApiSpec, null, 2),
  "utf-8",
);
console.log(`✔ Generated OpenAPI Specification: ${openApiFilePath}`);

// 3. Summary
const totalEndpoints = registeredFeatures.reduce(
  (acc, f) => acc + f.endpoints.length,
  0,
);
console.log(`\nFeatures documented (${registeredFeatures.length}):`);
for (const feature of registeredFeatures) {
  console.log(`  - ${feature.name}: ${feature.endpoints.length} endpoints`);
}
console.log(`Total Endpoints: ${totalEndpoints}`);
console.log(
  "\nDone! You can import 'kin.postman_collection.json' directly into Postman.",
);
