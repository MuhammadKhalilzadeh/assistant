import { Router } from 'express';
import { authController } from '../controllers/auth.controller';
import { validateBody } from '../middleware/validate.middleware';
import { googleAuthSchema, refreshTokenSchema, updateProfileSchema, gmailConnectSchema } from '../schemas/auth.schema';

const router = Router();

// Public routes (no JWT required)
router.post('/google', validateBody(googleAuthSchema), authController.googleAuth);
router.post('/refresh', validateBody(refreshTokenSchema), authController.refreshToken);

// Protected routes (JWT required — handled by auth middleware)
router.post('/logout', authController.logout);
router.get('/me', authController.getMe);
router.put('/me', validateBody(updateProfileSchema), authController.updateMe);
router.post('/gmail/connect', validateBody(gmailConnectSchema), authController.gmailConnect);

export default router;
