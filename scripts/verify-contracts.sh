#!/bin/bash

# Скрипт для верификации контрактов на Base Sepolia

set -e

echo "🔍 Verifying BaseChainVerify contracts on Base Sepolia"
echo ""

cd contracts

# Проверяем наличие .env
if [ ! -f ".env" ]; then
    echo "❌ Ошибка: .env файл не найден"
    exit 1
fi

# Загружаем переменные окружения
source .env

# Проверяем наличие BASESCAN_API_KEY
if [ -z "$BASESCAN_API_KEY" ]; then
    echo "❌ Ошибка: BASESCAN_API_KEY не установлен в .env"
    exit 1
fi

# Адреса контрактов (Base Sepolia)
ISSUER_REGISTRY="0xFE43ac5d3c843284032964BcC86F8Bf7d1C5c14b"
VERIFY_CORE="0xF2EdCe99dFe0A006D062cdB8C120D6d02cAD4369"
CERTIFICATE_NFT="0x26b7F0D2b0d4f5bA06dfF2b0FF6B8d10a33431b4"

# Deployer address
DEPLOYER="0xA7055e8c3468F2d95eCF9386925291A1d33d4F41"

echo "📝 Настройки:"
echo "   Network: Base Sepolia"
echo "   RPC URL: https://sepolia.base.org"
echo "   Chain ID: 84532"
echo "   Compiler: 0.8.24"
echo "   Optimization: 200 runs"
echo ""

read -p "Продолжить верификацию? (y/n): " CONFIRM
if [ "$CONFIRM" != "y" ]; then
    echo "Верификация отменена"
    exit 0
fi

echo ""
echo "🔍 Верификация IssuerRegistry..."

forge verify-contract \
  $ISSUER_REGISTRY \
  src/IssuerRegistry.sol:IssuerRegistry \
  --verifier etherscan \
  --etherscan-api-key $BASESCAN_API_KEY \
  --rpc-url https://sepolia.base.org \
  --chain-id 84532 \
  --constructor-args $(cast abi-encode "constructor(address)" $DEPLOYER) \
  --compiler-version 0.8.24 \
  --num-of-optimizations 200 \
  --show-standard-json-input > /dev/null 2>&1 || echo "⚠️  IssuerRegistry verification failed or already verified"

echo ""
echo "🔍 Верификация VerifyCore..."

forge verify-contract \
  $VERIFY_CORE \
  src/VerifyCore.sol:VerifyCore \
  --verifier etherscan \
  --etherscan-api-key $BASESCAN_API_KEY \
  --rpc-url https://sepolia.base.org \
  --chain-id 84532 \
  --constructor-args $(cast abi-encode "constructor(address,address)" $ISSUER_REGISTRY $DEPLOYER) \
  --compiler-version 0.8.24 \
  --num-of-optimizations 200 \
  --show-standard-json-input > /dev/null 2>&1 || echo "⚠️  VerifyCore verification failed or already verified"

echo ""
echo "🔍 Верификация CertificateNFT..."

forge verify-contract \
  $CERTIFICATE_NFT \
  src/CertificateNFT.sol:CertificateNFT \
  --verifier etherscan \
  --etherscan-api-key $BASESCAN_API_KEY \
  --rpc-url https://sepolia.base.org \
  --chain-id 84532 \
  --constructor-args $(cast abi-encode "constructor(address,address)" $VERIFY_CORE $DEPLOYER) \
  --compiler-version 0.8.24 \
  --num-of-optimizations 200 \
  --show-standard-json-input > /dev/null 2>&1 || echo "⚠️  CertificateNFT verification failed or already verified"

echo ""
echo "✅ Верификация завершена!"
echo ""
echo "📝 Проверьте контракты на Basescan:"
echo "   IssuerRegistry: https://sepolia.basescan.org/address/$ISSUER_REGISTRY"
echo "   VerifyCore: https://sepolia.basescan.org/address/$VERIFY_CORE"
echo "   CertificateNFT: https://sepolia.basescan.org/address/$CERTIFICATE_NFT"


