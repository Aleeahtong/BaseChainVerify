# 🔐 BaseChainVerify

**Prove anything, trustlessly.**

[![Built for Base](https://img.shields.io/badge/Built%20for-Base-0052FF?style=flat-square)](https://base.org)
[![Deployed on Base](https://img.shields.io/badge/Deployed%20on-Base%20Mainnet-0052FF?style=flat-square)](https://basescan.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](https://opensource.org/licenses/MIT)

> On-Chain Proof of Real-World Assets via Cryptographic Certificates on Base Network

BaseChainVerify is a decentralized system for verifying real-world documents (diplomas, certificates, licenses, memberships) on the Base blockchain. Documents are stored as cryptographic hashes on-chain, with optional IPFS storage and zero-knowledge proofs for privacy-preserving verification.

## 🎯 Overview

BaseChainVerify enables:

- ✅ **Upload real-world documents** (diplomas, certificates, licenses) as cryptographic hashes
- ✅ **Create verifiable proofs** via IPFS, SHA256 commitments, and ZK-proofs
- ✅ **Link certificates to wallet addresses** with transferable viewing rights
- ✅ **Public and private verification** for schools, employers, tech companies, courses
- ✅ **On-chain registry of validator organizations** (universities, companies, services)
- ✅ **Generate NFT certificates** containing issuer, type, docHash, metadata, and verifications

## 🏗️ Architecture

```
┌─────────────────┐
│   Frontend      │  Next.js + Wagmi + RainbowKit
│   (Next.js)     │
└────────┬────────┘
         │
┌────────▼────────┐
│   Backend API   │  Node.js + Express
│   (REST API)    │
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
┌───▼───┐ ┌──▼────┐
│ IPFS  │ │ Smart │  Base Network (Chain ID: 8453)
│       │ │Contracts│
└───────┘ └───────┘
```

## 📁 Project Structure

```
basechainverify/
├── contracts/              # Smart contracts (Foundry)
│   ├── VerifyCore.sol      # Core verification logic
│   ├── IssuerRegistry.sol  # Registry of verified issuers
│   ├── CertificateNFT.sol  # ERC-721 NFT certificates
│   ├── interfaces/
│   └── test/
├── backend/                # Backend services
│   ├── ipfs-upload.js      # IPFS upload handler
│   ├── hash-generator.js   # SHA256 hashing
│   ├── api.js              # REST API server
│   └── routes/
├── zk/                     # Zero-knowledge proofs (Phase 2)
│   ├── circuits/
│   └── proofs/
├── sdk/                    # JavaScript SDK
│   └── js/
├── frontend/               # Next.js frontend
│   ├── src/
│   ├── pages/
│   └── components/
├── docs/                   # Documentation
│   ├── whitepaper.md
│   ├── api.md
│   └── zk.md
├── scripts/                # Deployment scripts
└── .github/workflows/      # CI/CD
```

## 🚀 Quick Start

### Prerequisites

- **Node.js** ≥18.x
- **Foundry** ([Install](https://book.getfoundry.sh/getting-started/installation))
- **Git**

### Installation

```bash
# Clone repository
git clone https://github.com/yourusername/basechainverify.git
cd basechainverify

# Install all dependencies
npm run install:all
```

### Configuration

#### Smart Contracts

```bash
cd contracts
cp .env.example .env
# Edit .env with your values
```

#### Backend

```bash
cd backend
cp .env.example .env
# Edit .env with your values
```

#### Frontend

```bash
cd frontend
cp .env.example .env.local
# Edit .env.local with your values
```

### Development

```bash
# Smart Contracts
cd contracts
forge build
forge test

# Backend API
cd backend
npm run dev

# Frontend
cd frontend
npm run dev
```

## 📖 Usage

### Upload a Document

1. Connect your wallet
2. Upload your document (diploma, certificate, etc.)
3. Document is hashed and stored on-chain
4. Receive an NFT certificate

### Verify a Document

1. Enter document hash or scan QR code
2. System verifies against on-chain registry
3. View verification status and issuer information

### For Issuers

1. Register as an issuer organization
2. Issue certificates to users
3. Manage your certificate registry

## 🔗 Links

- **Base Mainnet Contract:** [View on Basescan](https://basescan.org/address/YOUR_CONTRACT_ADDRESS)
- **Frontend:** [Live Demo](https://basechainverify.vercel.app)
- **Documentation:** [Full Docs](./docs/)
- **API Documentation:** [API Docs](./docs/api.md)

## 🛠️ Technology Stack

- **Smart Contracts:** Solidity ≥0.8.20, Foundry
- **Frontend:** Next.js, React, Wagmi, RainbowKit
- **Backend:** Node.js, Express
- **Storage:** IPFS (via Pinata or Infura)
- **ZK Proofs:** Circom, SnarkJS (Phase 2)
- **Network:** Base (Chain ID: 8453)

## 📋 Roadmap

### Phase 1: MVP (2 weeks) ✅
- [x] VerifyCore.sol contract
- [x] IssuerRegistry.sol contract
- [x] CertificateNFT.sol contract
- [x] Backend: hashing + IPFS
- [x] Frontend: upload + verify
- [x] API: /verify, /store
- [x] Deploy Base Sepolia
- [x] README + documentation
- [x] GitHub Actions

### Phase 2: Full Version
- [ ] ZK circuits implementation
- [ ] Private verification mode
- [ ] Organization dashboard
- [ ] Issuer application process
- [ ] JS SDK release
- [ ] Enhanced UI/UX
- [ ] Deploy Base Mainnet

### Phase 3: Ecosystem Integration
- [ ] PR to Base ecosystem repos
- [ ] Integration with Base identity projects
- [ ] Community engagement
- [ ] Documentation site
- [ ] Video walkthrough

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built for [Base](https://base.org) ecosystem
- Inspired by verifiable credentials and decentralized identity
- Uses [OpenZeppelin](https://openzeppelin.com) contracts

## 📞 Contact

- **GitHub Issues:** [Open an issue](https://github.com/yourusername/basechainverify/issues)
- **Twitter:** [@BaseChainVerify](https://twitter.com/BaseChainVerify)
- **Discord:** [Base Builders](https://discord.gg/base)

---

**Built with ❤️ for Base**

*Chain ID: 8453 (Base Mainnet)*

