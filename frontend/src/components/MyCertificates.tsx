'use client'

import { useAccount, useReadContract } from 'wagmi'
import { useState, useEffect } from 'react'

const VERIFY_CORE_ABI = [
  {
    inputs: [{ name: 'owner', type: 'address' }],
    name: 'getDocumentsByOwner',
    outputs: [{ name: 'docHashes', type: 'bytes32[]' }],
    stateMutability: 'view',
    type: 'function'
  },
  {
    inputs: [{ name: 'docHash', type: 'bytes32' }],
    name: 'getDocumentMetadata',
    outputs: [
      { name: 'issuerId', type: 'uint256' },
      { name: 'owner', type: 'address' },
      { name: 'timestamp', type: 'uint256' },
      { name: 'isVerified', type: 'bool' }
    ],
    stateMutability: 'view',
    type: 'function'
  }
] as const

export function MyCertificates() {
  const { address, isConnected } = useAccount()
  const [certificates, setCertificates] = useState<any[]>([])

  const verifyCoreAddress = process.env.NEXT_PUBLIC_VERIFY_CORE_ADDRESS

  const { data: docHashes, isLoading } = useReadContract({
    address: verifyCoreAddress as `0x${string}`,
    abi: VERIFY_CORE_ABI,
    functionName: 'getDocumentsByOwner',
    args: address ? [address] : undefined,
    query: {
      enabled: !!address && isConnected,
    },
  })

  useEffect(() => {
    if (docHashes && Array.isArray(docHashes) && docHashes.length > 0) {
      // Fetch metadata for each document
      // This is a simplified version - in production, you'd want to batch these calls
      setCertificates(
        docHashes.map((hash: `0x${string}`) => ({
          hash,
          loading: true,
        }))
      )
    } else {
      setCertificates([])
    }
  }, [docHashes])

  if (!isConnected) {
    return <p className="text-gray-400">Connect your wallet to view certificates</p>
  }

  if (isLoading) {
    return <p className="text-gray-400">Loading certificates...</p>
  }

  if (!certificates || certificates.length === 0) {
    return <p className="text-gray-400">No certificates found</p>
  }

  return (
    <div className="space-y-4">
      {certificates.map((cert, index) => (
        <div
          key={index}
          className="p-4 bg-gray-100 dark:bg-gray-700 rounded-md border border-gray-200 dark:border-gray-600"
        >
          <div className="flex justify-between items-start">
            <div className="flex-1">
              <p className="text-sm font-medium mb-1">Document Hash</p>
              <p className="text-xs font-mono break-all text-gray-600 dark:text-gray-300">
                {cert.hash}
              </p>
            </div>
            <a
              href={`https://basescan.org/address/${verifyCoreAddress}`}
              target="_blank"
              rel="noopener noreferrer"
              className="text-blue-500 hover:underline text-xs ml-4"
            >
              View on Basescan
            </a>
          </div>
        </div>
      ))}
    </div>
  )
}

