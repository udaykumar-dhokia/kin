import {
  cloudinaryService,
  CloudinaryService,
  type CloudinaryUploadResult,
  type CloudinaryDeleteResult,
  type CloudinaryBatchDeleteResult,
  type UploadImageOptions,
  type DeleteImageOptions,
  type UploadFileInput,
} from "../services/cloudinary.service";

export const extractPublicIdFromUrl = (url: string): string | null => {
  return cloudinaryService.extractPublicIdFromUrl(url);
};

export {
  cloudinaryService,
  CloudinaryService,
  type CloudinaryUploadResult,
  type CloudinaryDeleteResult,
  type CloudinaryBatchDeleteResult,
  type UploadImageOptions,
  type DeleteImageOptions,
  type UploadFileInput,
};
