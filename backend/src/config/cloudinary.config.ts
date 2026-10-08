import { v2 as cloudinary } from "cloudinary";

/**
 * Checks whether the required Cloudinary credentials are provided in the environment.
 */
export const isCloudinaryConfigured = (): boolean => {
  return Boolean(
    (process.env.CLOUDINARY_CLOUD_NAME &&
      process.env.CLOUDINARY_API_KEY &&
      process.env.CLOUDINARY_API_SECRET) ||
      process.env.CLOUDINARY_URL
  );
};

/**
 * Configures Cloudinary with the current environment variables.
 */
export const configureCloudinary = (): typeof cloudinary => {
  if (process.env.CLOUDINARY_URL) {
    cloudinary.config({
      cloudinary_url: process.env.CLOUDINARY_URL,
      secure: true,
    });
  } else {
    cloudinary.config({
      cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
      api_key: process.env.CLOUDINARY_API_KEY,
      api_secret: process.env.CLOUDINARY_API_SECRET,
      secure: true,
    });
  }

  return cloudinary;
};

// Configure initially on load
configureCloudinary();
export { cloudinary };
export default cloudinary;

