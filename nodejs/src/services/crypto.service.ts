import { createCipheriv, createDecipheriv, randomBytes } from 'crypto';
import { logger } from '../config/logger';

const ALGORITHM = 'aes-256-gcm';
const IV_LENGTH = 16;
const TAG_LENGTH = 16;

function getEncryptionKey(): Buffer {
  const key = process.env.TOKEN_ENCRYPTION_KEY;
  if (!key) {
    logger.warn('TOKEN_ENCRYPTION_KEY not set, using fallback (unsafe for production)');
    return Buffer.from('0'.repeat(64), 'hex'); // 32 bytes
  }
  // If key is hex-encoded (64 chars = 32 bytes)
  if (key.length === 64) {
    return Buffer.from(key, 'hex');
  }
  // Otherwise hash it to get 32 bytes
  const { createHash } = require('crypto');
  return createHash('sha256').update(key).digest();
}

export const cryptoService = {
  encrypt(plaintext: string): string {
    const key = getEncryptionKey();
    const iv = randomBytes(IV_LENGTH);
    const cipher = createCipheriv(ALGORITHM, key, iv);

    let encrypted = cipher.update(plaintext, 'utf8', 'hex');
    encrypted += cipher.final('hex');
    const tag = cipher.getAuthTag();

    // Format: iv:tag:ciphertext (all hex)
    return `${iv.toString('hex')}:${tag.toString('hex')}:${encrypted}`;
  },

  decrypt(encryptedStr: string): string {
    const key = getEncryptionKey();
    const parts = encryptedStr.split(':');
    if (parts.length !== 3) {
      throw new Error('Invalid encrypted format');
    }

    const iv = Buffer.from(parts[0], 'hex');
    const tag = Buffer.from(parts[1], 'hex');
    const encrypted = parts[2];

    const decipher = createDecipheriv(ALGORITHM, key, iv);
    decipher.setAuthTag(tag);

    let decrypted = decipher.update(encrypted, 'hex', 'utf8');
    decrypted += decipher.final('utf8');
    return decrypted;
  },
};
