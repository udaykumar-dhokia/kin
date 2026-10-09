import { authDoc } from "../features/auth/auth.doc";
import { billsDoc } from "../features/bills/bills.doc";
import { familyDoc } from "../features/family/family.doc";
import type { FeatureDoc } from "./types";

/**
 * Central registry of all feature documentation modules in the Kin Life Admin OS.
 * To register documentation for a new feature, simply append its FeatureDoc here.
 */
export const registeredFeatures: FeatureDoc[] = [
  authDoc,
  billsDoc,
  familyDoc,
];

