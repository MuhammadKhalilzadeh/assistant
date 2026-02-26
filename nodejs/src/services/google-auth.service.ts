import { OAuth2Client } from 'google-auth-library';
import { logger } from '../config/logger';

const GOOGLE_CLIENT_ID = process.env.GOOGLE_CLIENT_ID || '';
const GOOGLE_CLIENT_SECRET = process.env.GOOGLE_CLIENT_SECRET || '';

const oauth2Client = new OAuth2Client(
  GOOGLE_CLIENT_ID,
  GOOGLE_CLIENT_SECRET,
  'postmessage' // for server auth code exchange
);

export interface GoogleUserInfo {
  googleId: string;
  email: string;
  displayName: string | null;
  photoUrl: string | null;
}

export interface GmailTokensResult {
  accessToken: string;
  refreshToken: string;
  expiry: Date;
}

export const googleAuthService = {
  async verifyIdToken(idToken: string): Promise<GoogleUserInfo | null> {
    try {
      const ticket = await oauth2Client.verifyIdToken({
        idToken,
        audience: GOOGLE_CLIENT_ID,
      });
      const payload = ticket.getPayload();
      if (!payload) return null;

      return {
        googleId: payload.sub,
        email: payload.email!,
        displayName: payload.name || null,
        photoUrl: payload.picture || null,
      };
    } catch (err) {
      logger.error({ err }, 'Failed to verify Google ID token');
      return null;
    }
  },

  async exchangeAuthCode(authCode: string): Promise<GmailTokensResult | null> {
    try {
      const { tokens } = await oauth2Client.getToken(authCode);

      if (!tokens.access_token) {
        logger.error('No access token received from Google');
        return null;
      }

      return {
        accessToken: tokens.access_token,
        refreshToken: tokens.refresh_token || '',
        expiry: tokens.expiry_date ? new Date(tokens.expiry_date) : new Date(Date.now() + 3600 * 1000),
      };
    } catch (err) {
      logger.error({ err }, 'Failed to exchange auth code for tokens');
      return null;
    }
  },

  getOAuth2Client(): OAuth2Client {
    return oauth2Client;
  },
};
