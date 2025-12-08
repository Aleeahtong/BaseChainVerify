import { ethers } from 'ethers';
import axios from 'axios';

export interface VerifyResult {
  verified: boolean;
  hash: string;
  issuerId?: string;
  owner?: string;
  timestamp?: string;
  isValid?: boolean;
}

export interface IssuerInfo {
  issuerId: string;
  name: string;
  metadataURI: string;
  isVerified: boolean;
  registeredAt: string;
}

export class BaseChainVerifySDK {
  private apiUrl: string;
  private provider: ethers.Provider;
  private verifyCoreAddress: string;
  private verifyCoreAbi: any[];

  constructor(
    apiUrl: string,
    provider: ethers.Provider,
    verifyCoreAddress: string,
    verifyCoreAbi: any[]
  ) {
    this.apiUrl = apiUrl;
    this.provider = provider;
    this.verifyCoreAddress = verifyCoreAddress;
    this.verifyCoreAbi = verifyCoreAbi;
  }

  /**
   * Generate hash from file
   */
  async generateHash(file: File): Promise<{ hash: string; bytes32: string }> {
    const formData = new FormData();
    formData.append('file', file);

    const response = await axios.post(`${this.apiUrl}/api/hash`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });

    return {
      hash: response.data.hash,
      bytes32: response.data.bytes32,
    };
  }

  /**
   * Upload file to IPFS
   */
  async uploadToIPFS(file: File): Promise<{
    cid: string;
    path: string;
    gatewayUrl: string;
    hash: string;
    bytes32: string;
  }> {
    const formData = new FormData();
    formData.append('file', file);

    const response = await axios.post(`${this.apiUrl}/api/ipfs/upload`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });

    return response.data;
  }

  /**
   * Verify document on-chain
   */
  async verifyDocument(hash: string): Promise<VerifyResult> {
    const normalizedHash = hash.startsWith('0x') ? hash : '0x' + hash;

    const response = await axios.get(`${this.apiUrl}/api/verify/${normalizedHash}`);
    return response.data;
  }

  /**
   * Get issuer information
   */
  async getIssuer(issuerId: string): Promise<IssuerInfo> {
    const response = await axios.get(`${this.apiUrl}/api/issuer/${issuerId}`);
    return response.data;
  }

  /**
   * Store document hash on-chain (requires signer)
   */
  async storeDocumentHash(
    signer: ethers.Signer,
    docHash: string,
    issuerId: number
  ): Promise<ethers.ContractTransactionResponse> {
    const contract = new ethers.Contract(
      this.verifyCoreAddress,
      this.verifyCoreAbi,
      signer
    );

    const normalizedHash = docHash.startsWith('0x') ? docHash : '0x' + docHash;
    return contract.storeDocumentHash(normalizedHash, issuerId);
  }

  /**
   * Get document metadata on-chain
   */
  async getDocumentMetadata(hash: string): Promise<{
    issuerId: bigint;
    owner: string;
    timestamp: bigint;
    isVerified: boolean;
  }> {
    const contract = new ethers.Contract(
      this.verifyCoreAddress,
      this.verifyCoreAbi,
      this.provider
    );

    const normalizedHash = hash.startsWith('0x') ? hash : '0x' + hash;
    return contract.getDocumentMetadata(normalizedHash);
  }
}

