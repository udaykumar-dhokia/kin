/**
 * Password utility for hashing and verifying passwords using Argon2id.
 * Follows OWASP recommendations: Argon2id with 64 MB memory cost (65536 KiB) and 3 iterations.
 */

export interface Argon2Options {
  memoryCost?: number;
  timeCost?: number;
}

const DEFAULT_MEMORY_COST = 65536; // 64 MB
const DEFAULT_TIME_COST = 3; // 3 iterations

/**
 * Hashes a plaintext password using the Argon2id algorithm.
 *
 * @param password - Plaintext password to hash
 * @param options - Optional custom Argon2 memory and time cost parameters
 * @returns Promise resolving to the Argon2id hash string ($argon2id$v=19$...)
 */
export async function hashPassword(
  password: string,
  options: Argon2Options = {},
): Promise<string> {
  if (!password || typeof password !== "string") {
    throw new Error("Password must be a non-empty string");
  }

  return Bun.password.hash(password, {
    algorithm: "argon2id",
    memoryCost: options.memoryCost ?? DEFAULT_MEMORY_COST,
    timeCost: options.timeCost ?? DEFAULT_TIME_COST,
  });
}

/**
 * Verifies a plaintext password against an Argon2id hash.
 *
 * @param password - Plaintext password to verify
 * @param hash - Argon2id hash to compare against
 * @returns Promise resolving to true if password matches, false otherwise
 */
export async function verifyPassword(
  password: string,
  hash: string,
): Promise<boolean> {
  if (!password || !hash) {
    return false;
  }

  try {
    return await Bun.password.verify(password, hash);
  } catch {
    return false;
  }
}
