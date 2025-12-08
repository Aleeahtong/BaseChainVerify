import express from 'express';
import cors from 'cors';
import multer from 'multer';
import dotenv from 'dotenv';
import { generateHash, toBytes32 } from './hash-generator.js';
import { uploadToIPFS, uploadMetadataToIPFS } from './ipfs-upload.js';
import { ethers } from 'ethers';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json());

// Configure multer for file uploads
const upload = multer({
    storage: multer.memoryStorage(),
    limits: {
        fileSize: 10 * 1024 * 1024 // 10MB limit
    }
});

// Initialize ethers provider
const getProvider = () => {
    const rpcUrl = process.env.NETWORK === 'mainnet'
        ? process.env.BASE_MAINNET_RPC || 'https://mainnet.base.org'
        : process.env.BASE_SEPOLIA_RPC || 'https://sepolia.base.org';
    
    return new ethers.JsonRpcProvider(rpcUrl);
};

// Contract ABIs (simplified - in production, import from artifacts)
const VERIFY_CORE_ABI = [
    "function storeDocumentHash(bytes32 docHash, uint256 issuerId) external returns (bool)",
    "function verifyDocument(bytes32 docHash) external view returns (bool isValid, uint256 issuerId, address owner)",
    "function getDocumentOwner(bytes32 docHash) external view returns (address owner)",
    "function getDocumentMetadata(bytes32 docHash) external view returns (uint256 issuerId, address owner, uint256 timestamp, bool isVerified)"
];

const ISSUER_REGISTRY_ABI = [
    "function registerIssuer(string memory name, string memory metadataURI) external returns (uint256 issuerId)",
    "function isIssuerVerified(uint256 issuerId) external view returns (bool isVerified)",
    "function getIssuer(uint256 issuerId) external view returns (string memory name, string memory metadataURI, bool isVerified, uint256 registeredAt)"
];

// Health check
app.get('/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Generate hash from uploaded file
app.post('/api/hash', upload.single('file'), async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ error: 'No file uploaded' });
        }

        const hash = generateHash(req.file.buffer);
        const bytes32Hash = toBytes32(hash);

        res.json({
            hash,
            bytes32: bytes32Hash,
            fileName: req.file.originalname,
            fileSize: req.file.size
        });
    } catch (error) {
        console.error('Hash generation error:', error);
        res.status(500).json({ error: error.message });
    }
});

// Upload file to IPFS
app.post('/api/ipfs/upload', upload.single('file'), async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ error: 'No file uploaded' });
        }

        const result = await uploadToIPFS(req.file.buffer, req.file.originalname);
        const hash = generateHash(req.file.buffer);
        const bytes32Hash = toBytes32(hash);

        res.json({
            ...result,
            hash,
            bytes32: bytes32Hash,
            fileName: req.file.originalname
        });
    } catch (error) {
        console.error('IPFS upload error:', error);
        res.status(500).json({ error: error.message });
    }
});

// Upload metadata to IPFS
app.post('/api/ipfs/metadata', async (req, res) => {
    try {
        const { metadata } = req.body;
        
        if (!metadata) {
            return res.status(400).json({ error: 'Metadata is required' });
        }

        const result = await uploadMetadataToIPFS(metadata);

        res.json(result);
    } catch (error) {
        console.error('IPFS metadata upload error:', error);
        res.status(500).json({ error: error.message });
    }
});

// Verify document on-chain
app.get('/api/verify/:hash', async (req, res) => {
    try {
        const hash = req.params.hash;
        const verifyCoreAddress = process.env.VERIFY_CORE_ADDRESS;

        if (!verifyCoreAddress) {
            return res.status(500).json({ error: 'VerifyCore address not configured' });
        }

        const provider = getProvider();
        const verifyCore = new ethers.Contract(verifyCoreAddress, VERIFY_CORE_ABI, provider);

        // Normalize hash - ensure it's a valid bytes32 (0x + 64 hex chars)
        let normalizedHash = hash.startsWith('0x') ? hash : '0x' + hash;
        // Ensure it's exactly 66 characters (0x + 64 hex)
        if (normalizedHash.length !== 66) {
            // Pad with zeros if needed
            const hashWithoutPrefix = normalizedHash.slice(2);
            normalizedHash = '0x' + hashWithoutPrefix.padStart(64, '0').slice(0, 64);
        }
        const docHash = normalizedHash;

        const [isValid, issuerId, owner] = await verifyCore.verifyDocument(docHash);

        if (!isValid) {
            return res.json({
                verified: false,
                hash: normalizedHash,
                message: 'Document not found or not verified'
            });
        }

        const metadata = await verifyCore.getDocumentMetadata(docHash);

        res.json({
            verified: true,
            hash: normalizedHash,
            issuerId: issuerId.toString(),
            owner: owner,
            timestamp: metadata.timestamp.toString(),
            isValid: metadata.isVerified
        });
    } catch (error) {
        console.error('Verification error:', error);
        res.status(500).json({ error: error.message });
    }
});

// Get issuer information
app.get('/api/issuer/:id', async (req, res) => {
    try {
        const issuerId = req.params.id;
        const issuerRegistryAddress = process.env.ISSUER_REGISTRY_ADDRESS;

        if (!issuerRegistryAddress) {
            return res.status(500).json({ error: 'IssuerRegistry address not configured' });
        }

        const provider = getProvider();
        const issuerRegistry = new ethers.Contract(issuerRegistryAddress, ISSUER_REGISTRY_ABI, provider);

        const [name, metadataURI, isVerified, registeredAt] = await issuerRegistry.getIssuer(issuerId);

        res.json({
            issuerId,
            name,
            metadataURI,
            isVerified,
            registeredAt: registeredAt.toString()
        });
    } catch (error) {
        console.error('Get issuer error:', error);
        res.status(500).json({ error: error.message });
    }
});

// Store document hash (requires signature - for frontend to call directly)
app.post('/api/store', async (req, res) => {
    try {
        // This endpoint is informational - actual storage happens on-chain via frontend
        const { hash, issuerId } = req.body;

        if (!hash || !issuerId) {
            return res.status(400).json({ error: 'Hash and issuerId are required' });
        }

        res.json({
            message: 'Use frontend to store document hash on-chain',
            hash,
            issuerId,
            verifyCoreAddress: process.env.VERIFY_CORE_ADDRESS
        });
    } catch (error) {
        console.error('Store error:', error);
        res.status(500).json({ error: error.message });
    }
});

// Start server
app.listen(PORT, () => {
    console.log(`🚀 BaseChainVerify API server running on port ${PORT}`);
    console.log(`📡 Network: ${process.env.NETWORK || 'sepolia'}`);
    console.log(`🔗 VerifyCore: ${process.env.VERIFY_CORE_ADDRESS || 'Not configured'}`);
});

