#!/bin/bash

# Скрипт для деплоя контрактов на Base Mainnet

set -e

echo "🚀 Deploying BaseChainVerify to Base Mainnet"
echo "⚠️  ВНИМАНИЕ: Это деплой в MAINNET!"
echo ""

cd contracts

# Проверяем наличие .env
if [ ! -f ".env" ]; then
    echo "❌ Ошибка: .env файл не найден"
    echo "Создайте .env файл из .env.example и заполните его"
    exit 1
fi

# Загружаем переменные окружения
source .env

# Проверяем наличие PRIVATE_KEY
if [ -z "$PRIVATE_KEY" ]; then
    echo "❌ Ошибка: PRIVATE_KEY не установлен в .env"
    exit 1
fi

# Проверяем наличие BASESCAN_API_KEY
if [ -z "$BASESCAN_API_KEY" ]; then
    echo "⚠️  Предупреждение: BASESCAN_API_KEY не установлен"
    echo "Контракты будут задеплоены, но не верифицированы"
    VERIFY_FLAG=""
    ETHERSCAN_KEY_FLAG=""
else
    # Используем etherscan verifier
    export BASESCAN_API_KEY
    VERIFY_FLAG="--verify --verifier etherscan"
    ETHERSCAN_KEY_FLAG="--etherscan-api-key $BASESCAN_API_KEY"
fi

echo "📝 Настройки:"
echo "   RPC URL: ${BASE_MAINNET_RPC_URL:-https://mainnet.base.org}"
echo "   Verifier: ${BASESCAN_API_KEY:+Basescan} ${BASESCAN_API_KEY:-None}"
echo ""

echo "⚠️  ПОДТВЕРЖДЕНИЕ:"
echo "   Вы собираетесь задеплоить контракты в Base Mainnet"
echo "   Это будет стоить реальных ETH"
echo "   Убедитесь, что:"
echo "   1. Контракты протестированы на Sepolia"
echo "   2. У вас достаточно ETH на Base Mainnet"
echo "   3. Вы готовы к деплою"
echo ""

read -p "ПОДТВЕРДИТЕ деплой в MAINNET (введите 'DEPLOY'): " CONFIRM
if [ "$CONFIRM" != "DEPLOY" ]; then
    echo "Деплой отменен"
    exit 0
fi

echo ""
echo "🔨 Деплой контрактов в Base Mainnet..."

# Экспортируем переменные для foundry.toml
export BASESCAN_API_KEY
export ETHERSCAN_API_URL="https://api.basescan.org/api"

forge script script/Deploy.s.sol:DeployScript \
  --rpc-url "${BASE_MAINNET_RPC_URL:-https://mainnet.base.org}" \
  --broadcast \
  $VERIFY_FLAG \
  $ETHERSCAN_KEY_FLAG \
  -vvvv

echo ""
echo "✅ Деплой в Mainnet завершен!"
echo ""
echo "📝 Обновите:"
echo "   - backend/.env (с mainnet адресами)"
echo "   - frontend/.env.local (с mainnet адресами, CHAIN_ID=8453)"
echo "   - README.md (добавьте mainnet адреса)"
echo "   - Vercel environment variables (CHAIN_ID=8453)"

