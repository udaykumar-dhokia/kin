import type {
  UploadApiOptions,
  TransformationOptions,
  DeliveryType,
} from "cloudinary";
import cloudinary, {
  isCloudinaryConfigured,
} from "../config/cloudinary.config";

/**
 * Supported file input types for uploading to Cloudinary.
 */
export type UploadFileInput = Buffer | string | Express.Multer.File;

/**
 * Options for configuring image upload.
 */
export interface UploadImageOptions extends Omit<UploadApiOptions, "folder"> {
  /**
   * The destination folder path in Cloudinary (e.g. 'avatars', 'kin/users').
   */
  folder?: string;

  /**
   * Optional custom public ID for the asset (excluding file extension).
   */
  publicId?: string;

  /**
   * Optional array of tags to categorize the asset.
   */
  tags?: string[];

  /**
   * Optional transformation options applied during upload.
   */
  transformation?: TransformationOptions | TransformationOptions[];

  /**
   * Whether to overwrite an existing asset with the same public ID. Default is false.
   */
  overwrite?: boolean;

  /**
   * The resource type of the asset. Default is 'image'.
   */
  resourceType?: "image" | "raw" | "auto" | "video";

  /**
   * Allowed file formats (e.g. ['jpg', 'png', 'webp']).
   */
  allowedFormats?: string[];
}

/**
 * Standardized upload response object returned across all upload operations.
 */
export interface CloudinaryUploadResult {
  publicId: string;
  url: string;
  secureUrl: string;
  format: string;
  width?: number;
  height?: number;
  bytes: number;
  resourceType: string;
  createdAt: string;
  originalFilename?: string;
}

/**
 * Options for asset deletion.
 */
export interface DeleteImageOptions {
  resourceType?: "image" | "raw" | "auto" | "video";
  invalidate?: boolean;
  type?: DeliveryType;
}

/**
 * Result of deleting a single asset.
 */
export interface CloudinaryDeleteResult {
  publicId: string;
  result: string;
  success: boolean;
}

/**
 * Result of deleting multiple assets in batch.
 */
export interface CloudinaryBatchDeleteResult {
  deleted: Record<string, string>;
  notFound: string[];
  partial: boolean;
  success: boolean;
}

/**
 * Generalized service for managing Cloudinary image uploads, deletions, and transformations.
 */
export class CloudinaryService {
  /**
   * Validates that Cloudinary credentials are configured.
   * Throws an error if required environment variables are missing.
   */
  private ensureConfigured(): void {
    if (!isCloudinaryConfigured()) {
      throw new Error(
        "Cloudinary is not configured. Please ensure CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, and CLOUDINARY_API_SECRET are set in your environment.",
      );
    }
  }

  /**
   * Uploads a single image to Cloudinary.
   *
   * Accepts:
   * - A `Buffer` (e.g. from Multer memory storage)
   * - An `Express.Multer.File` object
   * - A string (local file path, remote HTTP/HTTPS URL, or base64 data URI)
   *
   * @param file - The file input to upload.
   * @param options - Upload options (folder, transformations, publicId, etc.).
   * @returns Promise resolving to a standardized CloudinaryUploadResult.
   */
  public async uploadImage(
    file: UploadFileInput,
    options: UploadImageOptions = {},
  ): Promise<CloudinaryUploadResult> {
    this.ensureConfigured();

    const uploadOptions: UploadApiOptions = {
      resource_type: options.resourceType || "image",
      folder: options.folder,
      public_id: options.publicId,
      tags: options.tags,
      transformation: options.transformation,
      overwrite: options.overwrite ?? false,
      allowed_formats: options.allowedFormats,
      ...options,
    };

    // If input is an Express.Multer.File object
    if (this.isMulterFile(file)) {
      if (!uploadOptions.original_filename && file.originalname) {
        uploadOptions.original_filename = file.originalname;
      }
      return this.uploadBuffer(file.buffer, uploadOptions);
    }

    // If input is a raw Buffer
    if (Buffer.isBuffer(file)) {
      return this.uploadBuffer(file, uploadOptions);
    }

    // If input is a string (URL, base64 data URI, or local file path)
    if (typeof file === "string") {
      return this.uploadString(file, uploadOptions);
    }

    throw new Error("Invalid file input provided for Cloudinary upload.");
  }

  /**
   * Uploads multiple images to Cloudinary in parallel.
   *
   * @param files - Array of file inputs (Buffers, Multer files, URLs, or file paths).
   * @param options - Common upload options applied to all files.
   * @returns Promise resolving to an array of CloudinaryUploadResult.
   */
  public async uploadMultipleImages(
    files: UploadFileInput[],
    options: UploadImageOptions = {},
  ): Promise<CloudinaryUploadResult[]> {
    this.ensureConfigured();

    if (!Array.isArray(files) || files.length === 0) {
      return [];
    }

    const uploadPromises = files.map((file) => this.uploadImage(file, options));
    return Promise.all(uploadPromises);
  }

  /**
   * Deletes a single image by its Cloudinary public ID.
   *
   * @param publicId - The public ID of the resource to delete.
   * @param options - Deletion options (resource type, cache invalidation, etc.).
   * @returns Promise resolving to CloudinaryDeleteResult.
   */
  public async deleteImage(
    publicId: string,
    options: DeleteImageOptions = {},
  ): Promise<CloudinaryDeleteResult> {
    this.ensureConfigured();

    if (!publicId || typeof publicId !== "string") {
      throw new Error("A valid public ID is required to delete an image.");
    }

    const result = await cloudinary.uploader.destroy(publicId, {
      resource_type: options.resourceType || "image",
      invalidate: options.invalidate ?? true,
      type: options.type,
    });

    return {
      publicId,
      result: result.result,
      success: result.result === "ok",
    };
  }

  /**
   * Deletes multiple images by their Cloudinary public IDs.
   *
   * @param publicIds - Array of public IDs to delete.
   * @param options - Deletion options.
   * @returns Promise resolving to CloudinaryBatchDeleteResult.
   */
  public async deleteMultipleImages(
    publicIds: string[],
    options: DeleteImageOptions = {},
  ): Promise<CloudinaryBatchDeleteResult> {
    this.ensureConfigured();

    if (!Array.isArray(publicIds) || publicIds.length === 0) {
      return {
        deleted: {},
        notFound: [],
        partial: false,
        success: true,
      };
    }

    const response = await cloudinary.api.delete_resources(publicIds, {
      resource_type: options.resourceType || "image",
      invalidate: options.invalidate ?? true,
      type: options.type,
    });

    const deleted: Record<string, string> = response.deleted || {};
    const notFound: string[] = [];

    for (const [id, status] of Object.entries(deleted)) {
      if (status === "not_found") {
        notFound.push(id);
      }
    }

    const hasErrors = notFound.length > 0;

    return {
      deleted,
      notFound,
      partial: hasErrors && notFound.length < publicIds.length,
      success: !hasErrors,
    };
  }

  /**
   * Extracts the public ID from a standard Cloudinary image URL.
   * Handles URLs with subdirectories, versions (e.g. /v123456789/), and image format extensions.
   *
   * @example
   * extractPublicIdFromUrl('https://res.cloudinary.com/cloud/image/upload/v123/kin/avatars/user_1.jpg')
   * // returns 'kin/avatars/user_1'
   *
   * @param url - The full Cloudinary asset URL.
   * @returns The extracted public ID string, or null if the URL is invalid or not from Cloudinary.
   */
  public extractPublicIdFromUrl(url: string): string | null {
    if (!url || typeof url !== "string") {
      return null;
    }

    try {
      const uploadIndex = url.indexOf("/upload/");
      if (uploadIndex === -1) {
        return null;
      }

      let path = url.slice(uploadIndex + "/upload/".length);

      // Strip query parameters or hashes
      const queryIndex = path.indexOf("?");
      if (queryIndex !== -1) {
        path = path.substring(0, queryIndex);
      }
      const hashIndex = path.indexOf("#");
      if (hashIndex !== -1) {
        path = path.substring(0, hashIndex);
      }

      const segments = path.split("/");
      const filteredSegments: string[] = [];
      let passedVersion = false;

      for (const segment of segments) {
        if (!segment) continue;

        // Skip version strings like v1612345678
        if (/^v\d+$/.test(segment)) {
          passedVersion = true;
          continue;
        }

        // Before encountering a version tag, check if segment looks like transformations
        if (!passedVersion) {
          const isTransformation =
            /^(?:[a-z]{1,3}_[a-zA-Z0-9_.,-]+)(?:,[a-z]{1,3}_[a-zA-Z0-9_.,-]+)*$/.test(
              segment,
            ) || segment.includes(",");
          if (isTransformation) {
            continue;
          }
        }

        filteredSegments.push(segment);
      }

      if (filteredSegments.length === 0) {
        return null;
      }

      const fullPath = filteredSegments.join("/");

      // Strip extension from last segment
      const lastDotIndex = fullPath.lastIndexOf(".");
      if (lastDotIndex !== -1) {
        return fullPath.substring(0, lastDotIndex);
      }

      return fullPath;
    } catch {
      return null;
    }
  }

  /**
   * Generates an optimized or transformed delivery URL for a given public ID.
   *
   * @param publicId - The Cloudinary public ID.
   * @param options - Transformation options (width, height, crop, format, quality, etc.).
   * @returns The resulting Cloudinary CDN URL.
   */
  public getOptimizedUrl(
    publicId: string,
    options?: TransformationOptions,
  ): string {
    this.ensureConfigured();

    if (Array.isArray(options)) {
      return cloudinary.url(publicId, {
        secure: true,
        transformation: options,
      });
    }

    return cloudinary.url(publicId, {
      secure: true,
      fetch_format: "auto",
      quality: "auto",
      ...(options && typeof options === "object" ? options : {}),
    });
  }

  /**
   * Uploads a Buffer via upload_stream.
   */
  private uploadBuffer(
    buffer: Buffer,
    uploadOptions: UploadApiOptions,
  ): Promise<CloudinaryUploadResult> {
    return new Promise((resolve, reject) => {
      const uploadStream = cloudinary.uploader.upload_stream(
        uploadOptions,
        (error, result) => {
          if (error || !result) {
            return reject(
              error ||
                new Error("Cloudinary upload failed: empty response received."),
            );
          }

          resolve({
            publicId: result.public_id,
            url: result.url,
            secureUrl: result.secure_url,
            format: result.format,
            width: result.width,
            height: result.height,
            bytes: result.bytes,
            resourceType: result.resource_type,
            createdAt: result.created_at,
            originalFilename: result.original_filename,
          });
        },
      );

      uploadStream.end(buffer);
    });
  }

  /**
   * Uploads a string input (file path, URL, or data URI) via uploader.upload.
   */
  private async uploadString(
    input: string,
    uploadOptions: UploadApiOptions,
  ): Promise<CloudinaryUploadResult> {
    const result = await cloudinary.uploader.upload(input, uploadOptions);

    return {
      publicId: result.public_id,
      url: result.url,
      secureUrl: result.secure_url,
      format: result.format,
      width: result.width,
      height: result.height,
      bytes: result.bytes,
      resourceType: result.resource_type,
      createdAt: result.created_at,
      originalFilename: result.original_filename,
    };
  }

  /**
   * Type guard to check if an object is an Express.Multer.File.
   */
  private isMulterFile(file: unknown): file is Express.Multer.File {
    return (
      typeof file === "object" &&
      file !== null &&
      "buffer" in file &&
      Buffer.isBuffer((file as Express.Multer.File).buffer)
    );
  }
}

/**
 * Singleton instance of the CloudinaryService for convenient use across the application.
 */
export const cloudinaryService = new CloudinaryService();
