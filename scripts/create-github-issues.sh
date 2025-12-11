#!/bin/bash

# Скрипт для создания GitHub Issues
# Использование: ./scripts/create-github-issues.sh

set -e

GITHUB_USERNAME="Aleeahtong"
GITHUB_REPO="BaseChainVerify"
GITHUB_TOKEN="${GITHUB_TOKEN:-}"

API_URL="https://api.github.com/repos/${GITHUB_USERNAME}/${GITHUB_REPO}/issues"

echo "🚀 Создание GitHub Issues для BaseChainVerify"
echo ""

# Проверка токена
if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ Ошибка: GITHUB_TOKEN не установлен"
    echo "   Установите: export GITHUB_TOKEN=your_token"
    exit 1
fi

echo ""

# Функция для создания issue
create_issue() {
    local title="$1"
    local body="$2"
    local labels="$3"
    
    local json_data=$(cat <<EOF
{
  "title": "$title",
  "body": "$body",
  "labels": [$labels]
}
EOF
)
    
    response=$(curl -s -X POST \
        -H "Authorization: token ${GITHUB_TOKEN}" \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Content-Type: application/json" \
        -d "$json_data" \
        "$API_URL")
    
    issue_number=$(echo "$response" | grep -o '"number":[0-9]*' | head -1 | cut -d':' -f2)
    
    if [ -n "$issue_number" ]; then
        echo "✅ Created Issue #$issue_number: $title"
    else
        echo "❌ Failed to create: $title"
        echo "Response: $response"
    fi
}

# Issue #1: VerifyCore.sol (уже сделано - закрыть)
create_issue \
    "Implement VerifyCore.sol" \
    "Implement the core verification contract that stores and verifies document hashes on-chain.\n\n**Acceptance Criteria:**\n- [x] Contract stores document hashes with issuer ID\n- [x] Contract verifies document existence and validity\n- [x] Contract returns document metadata\n- [x] All tests pass\n- [x] Contract is documented with NatSpec comments\n\n✅ **COMPLETED**" \
    '"enhancement","contracts","MVP"'

# Issue #2: IssuerRegistry.sol (уже сделано - закрыть)
create_issue \
    "Implement IssuerRegistry.sol" \
    "Implement the issuer registry contract that manages verified organizations.\n\n**Acceptance Criteria:**\n- [x] Contract allows issuer registration\n- [x] Contract allows issuer removal (admin only)\n- [x] Contract verifies issuer status\n- [x] All tests pass\n- [x] Contract is documented with NatSpec comments\n\n✅ **COMPLETED**" \
    '"enhancement","contracts","MVP"'

# Issue #3: CertificateNFT.sol (уже сделано - закрыть)
create_issue \
    "Implement CertificateNFT.sol" \
    "Implement the ERC-721 NFT contract for certificate representation.\n\n**Acceptance Criteria:**\n- [x] Contract mints NFTs for verified documents\n- [x] Contract stores certificate metadata\n- [x] Contract links NFTs to document hashes\n- [x] All tests pass\n- [x] Contract is documented with NatSpec comments\n\n✅ **COMPLETED**" \
    '"enhancement","contracts","MVP","NFT"'

# Issue #4: Backend - IPFS Uploader
create_issue \
    "Backend - IPFS Uploader" \
    "Implement IPFS upload functionality for document storage.\n\n**Acceptance Criteria:**\n- [ ] Upload files to IPFS\n- [ ] Upload metadata to IPFS\n- [ ] Return IPFS CID and gateway URL\n- [ ] Handle errors gracefully\n- [ ] Support multiple IPFS providers (Infura, Pinata)" \
    '"enhancement","backend","MVP"'

# Issue #5: Backend - SHA256 Hashing
create_issue \
    "Backend - SHA256 Hashing" \
    "Implement SHA256 hash generation for documents.\n\n**Acceptance Criteria:**\n- [ ] Generate hash from file buffer\n- [ ] Generate hash from file path\n- [ ] Convert hash to bytes32 format\n- [ ] Verify hash matches file\n- [ ] Handle errors gracefully" \
    '"enhancement","backend","MVP"'

# Issue #6: Backend - Store/Verify API
create_issue \
    "Backend - Store/Verify API" \
    "Implement REST API endpoints for document operations.\n\n**Acceptance Criteria:**\n- [ ] POST /api/hash - Generate hash from file\n- [ ] POST /api/ipfs/upload - Upload file to IPFS\n- [ ] GET /api/verify/:hash - Verify document on-chain\n- [ ] GET /api/issuer/:id - Get issuer information\n- [ ] Error handling and validation\n- [ ] API documentation" \
    '"enhancement","backend","MVP","API"'

# Issue #7: Frontend - Upload Form
create_issue \
    "Frontend - Upload Form" \
    "Implement document upload interface.\n\n**Acceptance Criteria:**\n- [x] File upload component\n- [x] Hash generation display\n- [x] IPFS upload (optional)\n- [x] On-chain storage integration\n- [x] Loading states and error handling\n- [x] Responsive design\n\n✅ **COMPLETED**" \
    '"enhancement","frontend","MVP"'

# Issue #8: Frontend - Verify UI
create_issue \
    "Frontend - Verify UI" \
    "Implement document verification interface.\n\n**Acceptance Criteria:**\n- [x] Hash input field\n- [x] Verification status display\n- [x] Issuer information display\n- [x] Document metadata display\n- [x] Error handling\n- [x] Responsive design\n\n✅ **COMPLETED**" \
    '"enhancement","frontend","MVP"'

# Issue #9: Deployment Scripts (уже сделано - закрыть)
create_issue \
    "Deployment Scripts" \
    "Create deployment scripts for smart contracts.\n\n**Acceptance Criteria:**\n- [x] Foundry deployment script\n- [x] Base Sepolia deployment\n- [x] Base Mainnet deployment\n- [x] Contract verification\n- [x] Address saving to file\n\n✅ **COMPLETED**" \
    '"enhancement","devops","MVP"'

# Issue #10: README + Documentation (уже сделано - закрыть)
create_issue \
    "README + Documentation" \
    "Create comprehensive project documentation.\n\n**Acceptance Criteria:**\n- [x] README.md with project overview\n- [x] Architecture diagram\n- [x] Installation instructions\n- [x] Usage examples\n- [x] API documentation\n- [x] Roadmap\n\n✅ **COMPLETED**" \
    '"documentation","MVP"'

# Issue #11: GitHub Actions (уже есть - закрыть)
create_issue \
    "GitHub Actions" \
    "Set up CI/CD pipeline with GitHub Actions.\n\n**Acceptance Criteria:**\n- [x] Automated contract tests\n- [x] Frontend linting\n- [x] Backend tests (if applicable)\n- [x] Deployment automation (optional)\n- [x] Status badges\n\n✅ **COMPLETED**" \
    '"enhancement","ci/cd","MVP"'

echo ""
echo "✅ Все Issues созданы!"
echo ""
echo "📝 Следующие шаги:"
echo "   1. Перейдите на GitHub: https://github.com/${GITHUB_USERNAME}/${GITHUB_REPO}/issues"
echo "   2. Закройте выполненные Issues (#1, #2, #3, #7, #8, #9, #10, #11)"
echo "   3. Назначьте Issues на Milestone: MVP"

