# GitHub Issues Template

This file contains suggested GitHub issues to create for the project. Copy these into GitHub Issues when setting up the repository.

## Milestone: MVP

### Issue #1: Implement VerifyCore.sol
**Labels:** `enhancement`, `contracts`, `MVP`

Implement the core verification contract that stores and verifies document hashes on-chain.

**Acceptance Criteria:**
- [ ] Contract stores document hashes with issuer ID
- [ ] Contract verifies document existence and validity
- [ ] Contract returns document metadata
- [ ] All tests pass
- [ ] Contract is documented with NatSpec comments

---

### Issue #2: Implement IssuerRegistry.sol
**Labels:** `enhancement`, `contracts`, `MVP`

Implement the issuer registry contract that manages verified organizations.

**Acceptance Criteria:**
- [ ] Contract allows issuer registration
- [ ] Contract allows issuer removal (admin only)
- [ ] Contract verifies issuer status
- [ ] All tests pass
- [ ] Contract is documented with NatSpec comments

---

### Issue #3: Implement CertificateNFT.sol
**Labels:** `enhancement`, `contracts`, `MVP`, `NFT`

Implement the ERC-721 NFT contract for certificate representation.

**Acceptance Criteria:**
- [ ] Contract mints NFTs for verified documents
- [ ] Contract stores certificate metadata
- [ ] Contract links NFTs to document hashes
- [ ] All tests pass
- [ ] Contract is documented with NatSpec comments

---

### Issue #4: Backend - IPFS Uploader
**Labels:** `enhancement`, `backend`, `MVP`

Implement IPFS upload functionality for document storage.

**Acceptance Criteria:**
- [ ] Upload files to IPFS
- [ ] Upload metadata to IPFS
- [ ] Return IPFS CID and gateway URL
- [ ] Handle errors gracefully
- [ ] Support multiple IPFS providers (Infura, Pinata)

---

### Issue #5: Backend - SHA256 Hashing
**Labels:** `enhancement`, `backend`, `MVP`

Implement SHA256 hash generation for documents.

**Acceptance Criteria:**
- [ ] Generate hash from file buffer
- [ ] Generate hash from file path
- [ ] Convert hash to bytes32 format
- [ ] Verify hash matches file
- [ ] Handle errors gracefully

---

### Issue #6: Backend - Store/Verify API
**Labels:** `enhancement`, `backend`, `MVP`, `API`

Implement REST API endpoints for document operations.

**Acceptance Criteria:**
- [ ] POST /api/hash - Generate hash from file
- [ ] POST /api/ipfs/upload - Upload file to IPFS
- [ ] GET /api/verify/:hash - Verify document on-chain
- [ ] GET /api/issuer/:id - Get issuer information
- [ ] Error handling and validation
- [ ] API documentation

---

### Issue #7: Frontend - Upload Form
**Labels:** `enhancement`, `frontend`, `MVP`

Implement document upload interface.

**Acceptance Criteria:**
- [ ] File upload component
- [ ] Hash generation display
- [ ] IPFS upload (optional)
- [ ] On-chain storage integration
- [ ] Loading states and error handling
- [ ] Responsive design

---

### Issue #8: Frontend - Verify UI
**Labels:** `enhancement`, `frontend`, `MVP`

Implement document verification interface.

**Acceptance Criteria:**
- [ ] Hash input field
- [ ] Verification status display
- [ ] Issuer information display
- [ ] Document metadata display
- [ ] Error handling
- [ ] Responsive design

---

### Issue #9: Deployment Scripts
**Labels:** `enhancement`, `devops`, `MVP`

Create deployment scripts for smart contracts.

**Acceptance Criteria:**
- [ ] Foundry deployment script
- [ ] Base Sepolia deployment
- [ ] Base Mainnet deployment
- [ ] Contract verification
- [ ] Address saving to file

---

### Issue #10: README + Documentation
**Labels:** `documentation`, `MVP`

Create comprehensive project documentation.

**Acceptance Criteria:**
- [ ] README.md with project overview
- [ ] Architecture diagram
- [ ] Installation instructions
- [ ] Usage examples
- [ ] API documentation
- [ ] Roadmap

---

### Issue #11: GitHub Actions
**Labels:** `enhancement`, `ci/cd`, `MVP`

Set up CI/CD pipeline with GitHub Actions.

**Acceptance Criteria:**
- [ ] Automated contract tests
- [ ] Frontend linting
- [ ] Backend tests (if applicable)
- [ ] Deployment automation (optional)
- [ ] Status badges

---

## Milestone: Release

### Issue #12: ZK Circuits Base Version
**Labels:** `enhancement`, `zk-proofs`, `Phase 2`

Implement basic zero-knowledge proof circuits.

**Acceptance Criteria:**
- [ ] Circom circuit for document verification
- [ ] Proof generation
- [ ] Proof verification
- [ ] Integration with smart contracts
- [ ] Documentation

---

### Issue #13: Privacy-Preserving Proof Generation
**Labels:** `enhancement`, `zk-proofs`, `Phase 2`, `privacy`

Enable privacy-preserving document verification.

**Acceptance Criteria:**
- [ ] ZK proof for document validity without revealing content
- [ ] Age verification without revealing birthdate
- [ ] Qualification proof without revealing details
- [ ] Integration with frontend
- [ ] Documentation

---

### Issue #14: Frontend Redesign
**Labels:** `enhancement`, `frontend`, `UI/UX`

Improve frontend design and user experience.

**Acceptance Criteria:**
- [ ] Modern, polished UI
- [ ] Better UX flow
- [ ] Dark mode support
- [ ] Mobile responsive
- [ ] Accessibility improvements

---

### Issue #15: Issuer Dashboard
**Labels:** `enhancement`, `frontend`, `dashboard`

Create dashboard for issuer organizations.

**Acceptance Criteria:**
- [ ] Issuer registration interface
- [ ] Certificate issuance interface
- [ ] Statistics and analytics
- [ ] Document management
- [ ] User management

---

### Issue #16: JS SDK
**Labels:** `enhancement`, `sdk`, `Phase 2`

Release JavaScript SDK for easy integration.

**Acceptance Criteria:**
- [ ] TypeScript SDK
- [ ] NPM package
- [ ] Documentation
- [ ] Examples
- [ ] Tests

---

### Issue #17: Whitepaper
**Labels:** `documentation`, `Phase 2`

Write comprehensive whitepaper.

**Acceptance Criteria:**
- [ ] Technical specification
- [ ] Architecture details
- [ ] Security considerations
- [ ] Use cases
- [ ] Future roadmap

---

## Additional Issues

### Issue #18: Add Batch Verification
**Labels:** `enhancement`, `contracts`

Implement batch verification for multiple documents.

### Issue #19: Add Document Revocation
**Labels:** `enhancement`, `contracts`, `security`

Implement mechanism to revoke invalidated certificates.

### Issue #20: Multi-Chain Support
**Labels:** `enhancement`, `contracts`, `Phase 3`

Extend support to other EVM-compatible chains.

---

**Note:** Create these issues in GitHub and assign them to appropriate milestones. Update this file as issues are created and completed.

