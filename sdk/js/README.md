# BaseChainVerify JavaScript SDK

JavaScript SDK for interacting with BaseChainVerify contracts and API.

## Installation

```bash
npm install @basechainverify/sdk
```

## Usage

```typescript
import { BaseChainVerifySDK } from '@basechainverify/sdk';
import { ethers } from 'ethers';

// Initialize SDK
const provider = new ethers.JsonRpcProvider('https://sepolia.base.org');
const sdk = new BaseChainVerifySDK(
  'http://localhost:3001',
  provider,
  '0x...', // VerifyCore address
  [] // ABI
);

// Generate hash from file
const file = new File([...], 'document.pdf');
const { hash, bytes32 } = await sdk.generateHash(file);

// Verify document
const result = await sdk.verifyDocument(bytes32);
console.log(result.verified);
```

## License

MIT

