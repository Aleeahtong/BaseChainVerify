'use client'

import { ConnectButton } from '@rainbow-me/rainbowkit'
import { useAccount } from 'wagmi'
import { UploadDocument } from '@/components/UploadDocument'
import { VerifyDocument } from '@/components/VerifyDocument'
import { MyCertificates } from '@/components/MyCertificates'

export default function Home() {
  const { isConnected } = useAccount()

  return (
    <main className="min-h-screen p-8">
      <div className="max-w-6xl mx-auto">
        {/* Header */}
        <header className="flex justify-between items-center mb-12">
          <div>
            <h1 className="text-4xl font-bold mb-2">BaseChainVerify</h1>
            <p className="text-gray-400">Prove anything, trustlessly</p>
          </div>
          <ConnectButton />
        </header>

        {/* Main Content */}
        {isConnected ? (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
            {/* Upload Section */}
            <div className="bg-white dark:bg-gray-800 rounded-lg p-6 shadow-lg">
              <h2 className="text-2xl font-semibold mb-4">Upload Document</h2>
              <UploadDocument />
            </div>

            {/* Verify Section */}
            <div className="bg-white dark:bg-gray-800 rounded-lg p-6 shadow-lg">
              <h2 className="text-2xl font-semibold mb-4">Verify Document</h2>
              <VerifyDocument />
            </div>

            {/* My Certificates */}
            <div className="md:col-span-2 bg-white dark:bg-gray-800 rounded-lg p-6 shadow-lg">
              <h2 className="text-2xl font-semibold mb-4">My Certificates</h2>
              <MyCertificates />
            </div>
          </div>
        ) : (
          <div className="text-center py-20">
            <h2 className="text-2xl font-semibold mb-4">Connect Your Wallet</h2>
            <p className="text-gray-400 mb-8">
              Connect your wallet to start verifying documents on Base
            </p>
            <ConnectButton />
          </div>
        )}

        {/* Footer */}
        <footer className="mt-16 text-center text-gray-400">
          <p>Built for Base • Chain ID: {process.env.NEXT_PUBLIC_CHAIN_ID || '84532'}</p>
        </footer>
      </div>
    </main>
  )
}

