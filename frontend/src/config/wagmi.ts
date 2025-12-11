import { getDefaultConfig } from '@rainbow-me/rainbowkit'
import { base, baseSepolia } from 'wagmi/chains'

// Get chain ID from environment variable, default to Sepolia
const chainId = process.env.NEXT_PUBLIC_CHAIN_ID === '8453' ? base : baseSepolia

// Get WalletConnect project ID
const projectId = process.env.NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID || ''

if (!projectId) {
  console.warn('NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID is not set')
}

export const config = getDefaultConfig({
  appName: 'BaseChainVerify',
  projectId: projectId,
  chains: [chainId],
  ssr: true,
})

