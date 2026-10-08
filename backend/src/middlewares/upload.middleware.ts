import multer from "multer";
import type { Request } from "express";

// Default allowed image MIME types
export const DEFAULT_ALLOWED_IMAGE_MIMES = [
  "image/jpeg",
  "image/png",
  "image/webp",
  "image/gif",
  "image/svg+xml",
  "image/avif",
];

// Default max file size: 5 MB
export const DEFAULT_MAX_FILE_SIZE = 5 * 1024 * 1024;

export interface ImageUploadMiddlewareOptions {
  maxFileSize?: number;
  allowedMimes?: string[];
}

/**
 * Creates a configured Multer instance using memory storage and image validation.
 */
export const createImageUploadMiddleware = (
  options: ImageUploadMiddlewareOptions = {}
) => {
  const maxFileSize = options.maxFileSize ?? DEFAULT_MAX_FILE_SIZE;
  const allowedMimes = options.allowedMimes ?? DEFAULT_ALLOWED_IMAGE_MIMES;

  const storage = multer.memoryStorage();

  const fileFilter = (
    _req: Request,
    file: Express.Multer.File,
    cb: multer.FileFilterCallback
  ) => {
    if (allowedMimes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(
        new Error(
          `Unsupported file type: ${file.mimetype}. Allowed types: ${allowedMimes.join(", ")}`
        )
      );
    }
  };

  return multer({
    storage,
    limits: {
      fileSize: maxFileSize,
    },
    fileFilter,
  });
};

// Default image upload handler using standard memory storage and 5MB limit
export const upload = createImageUploadMiddleware();

/**
 * Middleware for handling a single image file upload.
 *
 * @param fieldName - The form-data field name (default: 'image').
 */
export const uploadSingleImage = (fieldName = "image") => upload.single(fieldName);

/**
 * Middleware for handling multiple image file uploads under the same field name.
 *
 * @param fieldName - The form-data field name (default: 'images').
 * @param maxCount - Maximum number of files to accept (default: 5).
 */
export const uploadMultipleImagesMiddleware = (
  fieldName = "images",
  maxCount = 5
) => upload.array(fieldName, maxCount);
