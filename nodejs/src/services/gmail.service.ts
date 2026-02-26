import { google } from 'googleapis';
import { OAuth2Client } from 'google-auth-library';
import { userModel } from '../models/user.model';
import { cryptoService } from './crypto.service';
import { logger } from '../config/logger';

const GOOGLE_CLIENT_ID = process.env.GOOGLE_CLIENT_ID || '';
const GOOGLE_CLIENT_SECRET = process.env.GOOGLE_CLIENT_SECRET || '';

interface GmailMessage {
  gmailMessageId: string;
  sender: string;
  subject: string;
  preview: string;
  receivedAt: Date;
  isRead: boolean;
}

function createOAuth2Client(accessToken: string, refreshToken: string): OAuth2Client {
  const client = new OAuth2Client(GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET);
  client.setCredentials({
    access_token: accessToken,
    refresh_token: refreshToken,
  });
  return client;
}

export const gmailService = {
  async fetchMessages(userId: string, maxResults: number = 20): Promise<GmailMessage[]> {
    const tokens = await userModel.getGmailTokens(userId);
    if (!tokens) {
      throw new Error('Gmail not connected');
    }

    // Decrypt stored tokens
    const accessToken = cryptoService.decrypt(tokens.accessToken);
    const refreshToken = cryptoService.decrypt(tokens.refreshToken);

    const oauth2Client = createOAuth2Client(accessToken, refreshToken);
    const gmail = google.gmail({ version: 'v1', auth: oauth2Client });

    // Fetch message list
    const listResponse = await gmail.users.messages.list({
      userId: 'me',
      maxResults,
      labelIds: ['INBOX'],
    });

    const messageIds = listResponse.data.messages || [];
    if (messageIds.length === 0) return [];

    // Fetch message details in parallel
    const messages: GmailMessage[] = [];

    for (const msg of messageIds) {
      try {
        const detail = await gmail.users.messages.get({
          userId: 'me',
          id: msg.id!,
          format: 'metadata',
          metadataHeaders: ['From', 'Subject', 'Date'],
        });

        const headers = detail.data.payload?.headers || [];
        const fromHeader = headers.find(h => h.name === 'From')?.value || 'Unknown';
        const subjectHeader = headers.find(h => h.name === 'Subject')?.value || '(No Subject)';
        const dateHeader = headers.find(h => h.name === 'Date')?.value;

        // Extract sender name from "Name <email>" format
        const senderMatch = fromHeader.match(/^(.+?)\s*<.+>$/);
        const sender = senderMatch ? senderMatch[1].replace(/"/g, '') : fromHeader;

        const isUnread = detail.data.labelIds?.includes('UNREAD') ?? false;

        messages.push({
          gmailMessageId: msg.id!,
          sender,
          subject: subjectHeader,
          preview: detail.data.snippet || '',
          receivedAt: dateHeader ? new Date(dateHeader) : new Date(),
          isRead: !isUnread,
        });
      } catch (err) {
        logger.warn({ err, messageId: msg.id }, 'Failed to fetch Gmail message detail');
      }
    }

    // Check if tokens were refreshed and update stored tokens
    const newCredentials = oauth2Client.credentials;
    if (newCredentials.access_token && newCredentials.access_token !== accessToken) {
      await userModel.updateGmailTokens(userId, {
        accessToken: cryptoService.encrypt(newCredentials.access_token),
        refreshToken: cryptoService.encrypt(newCredentials.refresh_token || refreshToken),
        expiry: newCredentials.expiry_date ? new Date(newCredentials.expiry_date) : new Date(Date.now() + 3600 * 1000),
      });
    }

    return messages;
  },

  async fetchMessageBody(userId: string, gmailMessageId: string): Promise<string> {
    const tokens = await userModel.getGmailTokens(userId);
    if (!tokens) {
      throw new Error('Gmail not connected');
    }

    const accessToken = cryptoService.decrypt(tokens.accessToken);
    const refreshToken = cryptoService.decrypt(tokens.refreshToken);

    const oauth2Client = createOAuth2Client(accessToken, refreshToken);
    const gmail = google.gmail({ version: 'v1', auth: oauth2Client });

    const detail = await gmail.users.messages.get({
      userId: 'me',
      id: gmailMessageId,
      format: 'full',
    });

    // Extract body from parts
    const parts = detail.data.payload?.parts || [];
    let body = '';

    // Try to find text/plain first, then text/html
    const textPart = parts.find(p => p.mimeType === 'text/plain');
    const htmlPart = parts.find(p => p.mimeType === 'text/html');

    if (textPart?.body?.data) {
      body = Buffer.from(textPart.body.data, 'base64url').toString('utf8');
    } else if (htmlPart?.body?.data) {
      body = Buffer.from(htmlPart.body.data, 'base64url').toString('utf8');
    } else if (detail.data.payload?.body?.data) {
      body = Buffer.from(detail.data.payload.body.data, 'base64url').toString('utf8');
    }

    return body;
  },
};
