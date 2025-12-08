import crypto from 'crypto';
import fs from 'fs';

/**
 * Generate SHA256 hash of a file
 * @param {Buffer|string} data - File buffer or file path
 * @returns {string} Hexadecimal hash string
 */
export function generateHash(data) {
    if (typeof data === 'string') {
        // If it's a file path, read the file
        const fileBuffer = fs.readFileSync(data);
        return crypto.createHash('sha256').update(fileBuffer).digest('hex');
    } else if (Buffer.isBuffer(data)) {
        // If it's a buffer, hash it directly
        return crypto.createHash('sha256').update(data).digest('hex');
    } else {
        throw new Error('Invalid input: expected file path (string) or Buffer');
    }
}

/**
 * Generate SHA256 hash from a string
 * @param {string} text - Text to hash
 * @returns {string} Hexadecimal hash string
 */
export function generateHashFromString(text) {
    return crypto.createHash('sha256').update(text, 'utf8').digest('hex');
}

/**
 * Convert hex hash to bytes32 format (for Solidity)
 * @param {string} hexHash - Hexadecimal hash string
 * @returns {string} bytes32 formatted hash (0x prefixed, 64 chars)
 */
export function toBytes32(hexHash) {
    if (hexHash.startsWith('0x')) {
        return hexHash;
    }
    return '0x' + hexHash;
}

/**
 * Verify hash matches file
 * @param {Buffer|string} data - File buffer or file path
 * @param {string} expectedHash - Expected hash (hex or bytes32)
 * @returns {boolean} True if hash matches
 */
export function verifyHash(data, expectedHash) {
    const computedHash = generateHash(data);
    const normalizedExpected = expectedHash.replace('0x', '').toLowerCase();
    const normalizedComputed = computedHash.toLowerCase();
    
    return normalizedComputed === normalizedExpected;
}

