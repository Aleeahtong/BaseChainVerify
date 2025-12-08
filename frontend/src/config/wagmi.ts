import { getDefaultConfig } from '@rainbow-me/rainbowkit'
import { base, baseSepolia } from 'wagmi/chains'

const chainId = process.env.NEXT_PUBLIC_CHAIN_ID === '8453' ? base : baseSepolia

export const config = getDefaultConfig({
  appName: 'BaseChainVerify',
  projectId: process.env.NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID || '',
  chains: [chainId],
  ssr: true,
})

