# BaseChainVerify Setup Guide

Quick setup guide for local development.

## Prerequisites

- **Node.js** ≥18.x ([Download](https://nodejs.org/))
- **Foundry** ([Install](https://book.getfoundry.sh/getting-started/installation))
- **Git**

## Quick Setup

### 1. Clone Repository

```bash
git clone https://github.com/yourusername/basechainverify.git
cd basechainverify
```

### 2. Install All Dependencies

```bash
npm run install:all
```

This will install dependencies for:
- Root package
- Smart contracts (Foundry)
- Frontend
- Backend
- SDK

### 3. Configure Environment Variables

#### Contracts

```bash
cd contracts
cp .env.example .env
# Edit .env with your values
```

For local development, you can use:
```bash
PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80  # Anvil default
BASE_SEPOLIA_RPC_URL=https://sepolia.base.org
BASE_MAINNET_RPC_URL=https://mainnet.base.org
BASESCAN_API_KEY=your_api_key_here
```

#### Backend

```bash
cd ../backend
cp .env.example .env
# Edit .env with your values
```

For local development:
```bash
NETWORK=sepolia
BASE_MAINNET_RPC=https://mainnet.base.org
BASE_SEPOLIA_RPC=https://sepolia.base.org
VERIFY_CORE_ADDRESS=
ISSUER_REGISTRY_ADDRESS=
CERTIFICATE_NFT_ADDRESS=
IPFS_URL=https://ipfs.infura.io:5001
IPFS_PROJECT_ID=
IPFS_PROJECT_SECRET=
PORT=3001
```

#### Frontend

```bash
cd ../frontend
cp .env.example .env.local
# Edit .env.local with your values
```

For local development:
```bash
NEXT_PUBLIC_API_URL=http://localhost:3001
NEXT_PUBLIC_REPUTE_CORE_ADDRESS=
NEXT_PUBLIC_ISSUER_REGISTRY_ADDRESS=
NEXT_PUBLIC_CERTIFICATE_NFT_ADDRESS=
NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=your_project_id
NEXT_PUBLIC_CHAIN_ID=84532
```

**Get WalletConnect Project ID:**
1. Go to [WalletConnect Cloud](https://cloud.walletconnect.com)
2. Create a new project
3. Copy the Project ID

## Development

### Smart Contracts

```bash
cd contracts

# Install OpenZeppelin
forge install OpenZeppelin/openzeppelin-contracts --no-commit

# Compile
forge build

# Run tests
forge test

# Run tests with verbose output
forge test -vvv

# Start local Anvil node
anvil

# Deploy to local Anvil (in another terminal)
forge script script/Deploy.s.sol:DeployScript --rpc-url http://localhost:8545 --broadcast
```

### Backend API

```bash
cd backend

# Start development server
npm run dev

# API will be available at http://localhost:3001
```

### Frontend

```bash
cd frontend

# Start development server
npm run dev

# Frontend will be available at http://localhost:3000
```

### SDK

```bash
cd sdk/js

# Build TypeScript
npm run build

# Run tests (if configured)
npm test
```

## Testing Locally

### 1. Start Local Blockchain

```bash
cd contracts
anvil
```

This starts a local Ethereum node at `http://localhost:8545`

### 2. Deploy Contracts Locally

In another terminal:
```bash
cd contracts
forge script script/Deploy.s.sol:DeployScript --rpc-url http://localhost:8545 --broadcast
```

Save the contract addresses from the output.

### 3. Update Configuration

Update Backend `.env`:
```bash
VERIFY_CORE_ADDRESS=0x... # from deployment output
ISSUER_REGISTRY_ADDRESS=0x... # from deployment output
CERTIFICATE_NFT_ADDRESS=0x... # from deployment output
```

Update Frontend `.env.local`:
```bash
NEXT_PUBLIC_VERIFY_CORE_ADDRESS=0x... # from deployment output
NEXT_PUBLIC_ISSUER_REGISTRY_ADDRESS=0x... # from deployment output
NEXT_PUBLIC_CERTIFICATE_NFT_ADDRESS=0x... # from deployment output
NEXT_PUBLIC_CHAIN_ID=31337 # Anvil default chain ID
```

### 4. Start Services

Terminal 1 - Backend:
```bash
cd backend
npm run dev
```

Terminal 2 - Frontend:
```bash
cd frontend
npm run dev
```

### 5. Connect Wallet

1. Open http://localhost:3000
2. Connect wallet (MetaMask)
3. Add Anvil network:
   - Network Name: Anvil
   - RPC URL: http://localhost:8545
   - Chain ID: 31337
   - Currency Symbol: ETH
4. Import Anvil account (private key: `0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80`)

## Troubleshooting

### Contracts won't compile

```bash
cd contracts
forge install OpenZeppelin/openzeppelin-contracts --no-commit
forge build
```

### Frontend won't start

```bash
cd frontend
rm -rf node_modules .next
npm install
npm run dev
```

### Backend can't connect to contracts

- Verify contract addresses in `.env`
- Check RPC URL is correct
- Ensure contracts are deployed

### WalletConnect errors

- Verify `NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID` is set
- Check project ID is valid in WalletConnect Cloud

## Next Steps

Once local setup is working:

1. Test on Base Sepolia (see [contracts/README.md](./contracts/README.md))
2. Deploy to Base Mainnet
3. Share with community!

---

**Need help?** Open an issue on GitHub!

