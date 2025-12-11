#!/bin/bash

# Скрипт для деплоя контрактов на Base Sepolia

set -e

echo "🚀 Deploying BaseChainVerify to Base Sepolia"
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
echo "   RPC URL: ${BASE_SEPOLIA_RPC_URL:-https://sepolia.base.org}"
echo "   Verifier: ${BASESCAN_API_KEY:+Basescan} ${BASESCAN_API_KEY:-None}"
echo ""

read -p "Продолжить деплой? (y/n): " CONFIRM
if [ "$CONFIRM" != "y" ]; then
    echo "Деплой отменен"
    exit 0
fi

echo ""
echo "🔨 Деплой контрактов..."

# Экспортируем переменные для foundry.toml
export BASESCAN_API_KEY
export ETHERSCAN_API_URL="https://api-sepolia.basescan.org/api"

forge script script/Deploy.s.sol:DeployScript \
  --rpc-url "${BASE_SEPOLIA_RPC_URL:-https://sepolia.base.org}" \
  --broadcast \
  $VERIFY_FLAG \
  $ETHERSCAN_KEY_FLAG \
  -vvvv

echo ""
echo "✅ Деплой завершен!"
echo ""
echo "📝 Сохраните адреса контрактов и обновите:"
echo "   - backend/.env"
echo "   - frontend/.env.local"
echo "   - README.md"

