'use client'

import { useState } from 'react'
import { useAccount, useWriteContract, useWaitForTransactionReceipt } from 'wagmi'
import { parseEther } from 'viem'
import axios from 'axios'

const VERIFY_CORE_ABI = [
  {
    inputs: [
      { name: 'docHash', type: 'bytes32' },
      { name: 'issuerId', type: 'uint256' }
    ],
    name: 'storeDocumentHash',
    outputs: [{ name: '', type: 'bool' }],
    stateMutability: 'nonpayable',
    type: 'function'
  }
] as const

export function UploadDocument() {
  const { address, isConnected } = useAccount()
  const [file, setFile] = useState<File | null>(null)
  const [issuerId, setIssuerId] = useState('')
  const [loading, setLoading] = useState(false)
  const [hash, setHash] = useState('')
  const [ipfsCid, setIpfsCid] = useState('')

  const { writeContract, data: txHash, isPending } = useWriteContract()
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({
    hash: txHash,
  })

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      setFile(e.target.files[0])
    }
  }

  const handleUpload = async () => {
    if (!file || !issuerId || !isConnected) return

    setLoading(true)
    try {
      // Step 1: Generate hash
      const formData = new FormData()
      formData.append('file', file)

      const hashResponse = await axios.post(
        `${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'}/api/hash`,
        formData,
        { headers: { 'Content-Type': 'multipart/form-data' } }
      )

      const docHash = hashResponse.data.bytes32
      setHash(docHash)

      // Step 2: Upload to IPFS (optional)
      try {
        const ipfsResponse = await axios.post(
          `${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'}/api/ipfs/upload`,
          formData,
          { headers: { 'Content-Type': 'multipart/form-data' } }
        )
        setIpfsCid(ipfsResponse.data.cid)
      } catch (error) {
        console.error('IPFS upload failed:', error)
      }

      // Step 3: Store on-chain
      const verifyCoreAddress = process.env.NEXT_PUBLIC_VERIFY_CORE_ADDRESS
      if (!verifyCoreAddress) {
        throw new Error('VerifyCore address not configured')
      }

      writeContract({
        address: verifyCoreAddress as `0x${string}`,
        abi: VERIFY_CORE_ABI,
        functionName: 'storeDocumentHash',
        args: [docHash as `0x${string}`, BigInt(issuerId)],
      })
    } catch (error: any) {
      console.error('Upload error:', error)
      alert(`Error: ${error.message}`)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="space-y-4">
      <div>
        <label className="block text-sm font-medium mb-2">Document File</label>
        <input
          type="file"
          onChange={handleFileChange}
          className="block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-md file:border-0 file:text-sm file:font-semibold file:bg-base-blue file:text-white hover:file:bg-blue-600"
        />
      </div>

      <div>
        <label className="block text-sm font-medium mb-2">Issuer ID</label>
        <input
          type="number"
          value={issuerId}
          onChange={(e) => setIssuerId(e.target.value)}
          placeholder="Enter issuer ID"
          className="w-full px-4 py-2 border border-gray-300 rounded-md dark:bg-gray-700 dark:border-gray-600"
        />
      </div>

      <button
        onClick={handleUpload}
        disabled={!file || !issuerId || loading || isPending || isConfirming}
        className="w-full bg-base-blue text-white py-2 px-4 rounded-md hover:bg-blue-600 disabled:opacity-50 disabled:cursor-not-allowed"
      >
        {loading || isPending || isConfirming
          ? 'Processing...'
          : isSuccess
          ? 'Uploaded!'
          : 'Upload & Store on Chain'}
      </button>

      {hash && (
        <div className="mt-4 p-4 bg-gray-100 dark:bg-gray-700 rounded-md">
          <p className="text-sm font-medium">Document Hash:</p>
          <p className="text-xs break-all font-mono">{hash}</p>
        </div>
      )}

      {ipfsCid && (
        <div className="mt-2 p-4 bg-gray-100 dark:bg-gray-700 rounded-md">
          <p className="text-sm font-medium">IPFS CID:</p>
          <p className="text-xs break-all font-mono">{ipfsCid}</p>
          <a
            href={`https://ipfs.io/ipfs/${ipfsCid}`}
            target="_blank"
            rel="noopener noreferrer"
            className="text-blue-500 hover:underline text-xs"
          >
            View on IPFS
          </a>
        </div>
      )}

      {isSuccess && (
        <div className="mt-4 p-4 bg-green-100 dark:bg-green-900 rounded-md">
          <p className="text-sm text-green-800 dark:text-green-200">
            ✅ Document stored successfully on-chain!
          </p>
          {txHash && (
            <a
              href={`https://basescan.org/tx/${txHash}`}
              target="_blank"
              rel="noopener noreferrer"
              className="text-blue-500 hover:underline text-xs"
            >
              View transaction
            </a>
          )}
        </div>
      )}
    </div>
  )
}

