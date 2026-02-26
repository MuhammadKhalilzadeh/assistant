import { z } from 'zod';

export const googleAuthSchema = z.object({
  idToken: z.string({ required_error: 'Google ID token is required' }).min(1),
  authCode: z.string().optional().nullable(),
});

export const refreshTokenSchema = z.object({
  refreshToken: z.string({ required_error: 'Refresh token is required' }).min(1),
});

export const updateProfileSchema = z.object({
  nickname: z
    .string()
    .min(1, 'Nickname cannot be empty')
    .max(100, 'Nickname must be 100 characters or less')
    .transform((val) => val.trim()),
});

export const gmailConnectSchema = z.object({
  authCode: z.string({ required_error: 'Auth code is required' }).min(1),
});

export type GoogleAuthInput = z.infer<typeof googleAuthSchema>;
export type RefreshTokenInput = z.infer<typeof refreshTokenSchema>;
export type UpdateProfileInput = z.infer<typeof updateProfileSchema>;
export type GmailConnectInput = z.infer<typeof gmailConnectSchema>;
