'use client'

import { useState } from 'react'
import { useReadContract } from 'wagmi'
import axios from 'axios'

const VERIFY_CORE_ABI = [
  {
    inputs: [{ name: 'docHash', type: 'bytes32' }],
    name: 'verifyDocument',
    outputs: [
      { name: 'isValid', type: 'bool' },
      { name: 'issuerId', type: 'uint256' },
      { name: 'owner', type: 'address' }
    ],
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

export function VerifyDocument() {
  const [docHash, setDocHash] = useState('')
  const [verificationResult, setVerificationResult] = useState<any>(null)

  const verifyCoreAddress = process.env.NEXT_PUBLIC_VERIFY_CORE_ADDRESS

  const { data, isLoading, error } = useReadContract({
    address: verifyCoreAddress as `0x${string}`,
    abi: VERIFY_CORE_ABI,
    functionName: 'verifyDocument',
    args: docHash ? [docHash as `0x${string}`] : undefined,
    query: {
      enabled: !!docHash && docHash.length === 66, // 0x + 64 hex chars
    },
  })

  const handleVerify = async () => {
    if (!docHash) return

    try {
      // Normalize hash - ensure it's a valid bytes32 (0x + 64 hex chars)
      let normalizedHash = docHash.startsWith('0x') ? docHash : '0x' + docHash
      // Ensure it's exactly 66 characters (0x + 64 hex)
      if (normalizedHash.length !== 66) {
        const hashWithoutPrefix = normalizedHash.slice(2)
        normalizedHash = '0x' + hashWithoutPrefix.padStart(64, '0').slice(0, 64)
      }

      // Verify via API
      const response = await axios.get(
        `${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'}/api/verify/${normalizedHash}`
      )

      setVerificationResult(response.data)

      // If verified, get issuer info
      if (response.data.verified && response.data.issuerId) {
        try {
          const issuerResponse = await axios.get(
            `${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'}/api/issuer/${response.data.issuerId}`
          )
          setVerificationResult((prev: any) => ({
            ...prev,
            issuer: issuerResponse.data,
          }))
        } catch (error) {
          console.error('Failed to fetch issuer info:', error)
        }
      }
    } catch (error: any) {
      console.error('Verification error:', error)
      setVerificationResult({
        verified: false,
        error: error.message,
      })
    }
  }

  return (
    <div className="space-y-4">
      <div>
        <label className="block text-sm font-medium mb-2">Document Hash</label>
        <input
          type="text"
          value={docHash}
          onChange={(e) => setDocHash(e.target.value)}
          placeholder="0x..."
          className="w-full px-4 py-2 border border-gray-300 rounded-md dark:bg-gray-700 dark:border-gray-600 font-mono text-sm"
        />
      </div>

      <button
        onClick={handleVerify}
        disabled={!docHash || isLoading}
        className="w-full bg-base-blue text-white py-2 px-4 rounded-md hover:bg-blue-600 disabled:opacity-50 disabled:cursor-not-allowed"
      >
        {isLoading ? 'Verifying...' : 'Verify Document'}
      </button>

      {verificationResult && (
        <div
          className={`mt-4 p-4 rounded-md ${
            verificationResult.verified
              ? 'bg-green-100 dark:bg-green-900'
              : 'bg-red-100 dark:bg-red-900'
          }`}
        >
          {verificationResult.verified ? (
            <div>
              <p className="text-green-800 dark:text-green-200 font-semibold mb-2">
                ✅ Document Verified
              </p>
              <div className="text-sm space-y-1">
                <p>
                  <span className="font-medium">Owner:</span>{' '}
                  <span className="font-mono">{verificationResult.owner}</span>
                </p>
                <p>
                  <span className="font-medium">Issuer ID:</span> {verificationResult.issuerId}
                </p>
                {verificationResult.issuer && (
                  <p>
                    <span className="font-medium">Issuer:</span>{' '}
                    {verificationResult.issuer.name}
                  </p>
                )}
                {verificationResult.timestamp && (
                  <p>
                    <span className="font-medium">Stored:</span>{' '}
                    {new Date(Number(verificationResult.timestamp) * 1000).toLocaleString()}
                  </p>
                )}
              </div>
            </div>
          ) : (
            <p className="text-red-800 dark:text-red-200">
              ❌ Document not found or not verified
            </p>
          )}
        </div>
      )}

      {error && (
        <div className="mt-4 p-4 bg-red-100 dark:bg-red-900 rounded-md">
          <p className="text-red-800 dark:text-red-200 text-sm">Error: {error.message}</p>
        </div>
      )}
    </div>
  )
}

