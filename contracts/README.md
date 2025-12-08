# BaseChainVerify Smart Contracts

Smart contracts for BaseChainVerify deployed on Base network.

## Contracts

- **IssuerRegistry**: Registry of verified organizations that can issue certificates
- **VerifyCore**: Core contract for storing and verifying document hashes
- **CertificateNFT**: ERC-721 NFTs representing verified certificates

## Setup

### Install Foundry

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### Install Dependencies

```bash
forge install OpenZeppelin/openzeppelin-contracts --no-commit
```

### Configure Environment

```bash
cp .env.example .env
# Edit .env with your values
```

## Build

```bash
forge build
```

## Test

```bash
forge test
```

## Deploy

### Deploy to Base Sepolia

```bash
forge script script/Deploy.s.sol:DeployScript \
  --rpc-url $BASE_SEPOLIA_RPC_URL \
  --broadcast \
  --verify \
  --verifier basescan \
  --verifier-url https://api-sepolia.basescan.org/api
```

### Deploy to Base Mainnet

```bash
forge script script/Deploy.s.sol:DeployScript \
  --rpc-url $BASE_MAINNET_RPC_URL \
  --broadcast \
  --verify \
  --verifier basescan \
  --verifier-url https://api.basescan.org/api
```

## Contract Addresses

### Base Sepolia

- IssuerRegistry: `TBD`
- VerifyCore: `TBD`
- CertificateNFT: `TBD`

### Base Mainnet

- IssuerRegistry: `TBD`
- VerifyCore: `TBD`
- CertificateNFT: `TBD`

## License

MIT

