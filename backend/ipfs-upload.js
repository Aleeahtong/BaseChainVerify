import { create } from 'ipfs-http-client';
import fs from 'fs';
import dotenv from 'dotenv';

dotenv.config();

/**
 * IPFS client configuration
 * Supports multiple IPFS providers:
 * - Infura: https://ipfs.infura.io:5001
 * - Pinata: https://api.pinata.cloud
 * - Local: http://localhost:5001
 */
let ipfsClient = null;

function getIPFSClient() {
    if (ipfsClient) {
        return ipfsClient;
    }

    const ipfsUrl = process.env.IPFS_URL || 'https://ipfs.infura.io:5001';
    const ipfsProjectId = process.env.IPFS_PROJECT_ID;
    const ipfsProjectSecret = process.env.IPFS_PROJECT_SECRET;

    const auth = ipfsProjectId && ipfsProjectSecret
        ? `${ipfsProjectId}:${ipfsProjectSecret}`
        : undefined;

    ipfsClient = create({
        url: ipfsUrl,
        headers: auth ? {
            authorization: `Basic ${Buffer.from(auth).toString('base64')}`
        } : {}
    });

    return ipfsClient;
}

/**
 * Upload a file to IPFS
 * @param {Buffer|string} fileData - File buffer or file path
 * @param {string} fileName - Optional file name
 * @returns {Promise<{cid: string, path: string}>} IPFS CID and path
 */
export async function uploadToIPFS(fileData, fileName = 'document') {
    try {
        const client = getIPFSClient();
        
        let content;
        if (Buffer.isBuffer(fileData)) {
            content = fileData;
        } else if (typeof fileData === 'string') {
            content = fs.readFileSync(fileData);
        } else {
            throw new Error('Invalid file data: expected Buffer or file path');
        }

        const result = await client.add({
            path: fileName,
            content: content
        }, {
            pin: true
        });

        const cid = result.cid.toString();
        const ipfsPath = `ipfs://${cid}`;
        const gatewayUrl = `https://ipfs.io/ipfs/${cid}`;

        return {
            cid,
            path: ipfsPath,
            gatewayUrl,
            size: result.size
        };
    } catch (error) {
        console.error('IPFS upload error:', error);
        throw new Error(`Failed to upload to IPFS: ${error.message}`);
    }
}

/**
 * Upload JSON metadata to IPFS
 * @param {object} metadata - JSON object to upload
 * @returns {Promise<{cid: string, path: string}>} IPFS CID and path
 */
export async function uploadMetadataToIPFS(metadata) {
    try {
        const client = getIPFSClient();
        
        const jsonString = JSON.stringify(metadata, null, 2);
        const jsonBuffer = Buffer.from(jsonString, 'utf8');

        const result = await client.add({
            path: 'metadata.json',
            content: jsonBuffer
        }, {
            pin: true
        });

        const cid = result.cid.toString();
        const ipfsPath = `ipfs://${cid}`;
        const gatewayUrl = `https://ipfs.io/ipfs/${cid}`;

        return {
            cid,
            path: ipfsPath,
            gatewayUrl,
            size: result.size
        };
    } catch (error) {
        console.error('IPFS metadata upload error:', error);
        throw new Error(`Failed to upload metadata to IPFS: ${error.message}`);
    }
}

/**
 * Pin a CID to IPFS (for Pinata or other pinning services)
 * @param {string} cid - IPFS CID to pin
 * @returns {Promise<boolean>} Success status
 */
export async function pinToIPFS(cid) {
    try {
        // This is a placeholder - implement based on your pinning service
        // For Pinata, you would use their API
        // For Infura, pinning happens automatically with the add() call
        
        console.log(`Pinning CID: ${cid}`);
        return true;
    } catch (error) {
        console.error('IPFS pin error:', error);
        return false;
    }
}

/**
 * Get file from IPFS
 * @param {string} cid - IPFS CID
 * @returns {Promise<Buffer>} File buffer
 */
export async function getFromIPFS(cid) {
    try {
        const client = getIPFSClient();
        const chunks = [];
        
        for await (const chunk of client.cat(cid)) {
            chunks.push(chunk);
        }
        
        return Buffer.concat(chunks);
    } catch (error) {
        console.error('IPFS get error:', error);
        throw new Error(`Failed to get from IPFS: ${error.message}`);
    }
}

