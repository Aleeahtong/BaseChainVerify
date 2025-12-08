# BaseChainVerify API Documentation

## Base URL

```
http://localhost:3001  (development)
https://api.basechainverify.com  (production)
```

## Endpoints

### Health Check

#### `GET /health`

Check API health status.

**Response:**
```json
{
  "status": "ok",
  "timestamp": "2025-01-27T12:00:00.000Z"
}
```

---

### Hash Generation

#### `POST /api/hash`

Generate SHA256 hash of an uploaded file.

**Request:**
- Method: `POST`
- Content-Type: `multipart/form-data`
- Body:
  - `file`: File to hash

**Response:**
```json
{
  "hash": "a1b2c3d4e5f6...",
  "bytes32": "0xa1b2c3d4e5f6...",
  "fileName": "document.pdf",
  "fileSize": 1024
}
```

---

### IPFS Upload

#### `POST /api/ipfs/upload`

Upload a file to IPFS.

**Request:**
- Method: `POST`
- Content-Type: `multipart/form-data`
- Body:
  - `file`: File to upload

**Response:**
```json
{
  "cid": "QmXxxx...",
  "path": "ipfs://QmXxxx...",
  "gatewayUrl": "https://ipfs.io/ipfs/QmXxxx...",
  "size": 1024,
  "hash": "a1b2c3d4e5f6...",
  "bytes32": "0xa1b2c3d4e5f6...",
  "fileName": "document.pdf"
}
```

---

### IPFS Metadata Upload

#### `POST /api/ipfs/metadata`

Upload JSON metadata to IPFS.

**Request:**
- Method: `POST`
- Content-Type: `application/json`
- Body:
```json
{
  "metadata": {
    "name": "Certificate Name",
    "description": "Certificate Description",
    "issuer": "University Name",
    "date": "2025-01-27"
  }
}
```

**Response:**
```json
{
  "cid": "QmYxxx...",
  "path": "ipfs://QmYxxx...",
  "gatewayUrl": "https://ipfs.io/ipfs/QmYxxx...",
  "size": 256
}
```

---

### Verify Document

#### `GET /api/verify/:hash`

Verify a document hash on-chain.

**Parameters:**
- `hash`: Document hash (with or without 0x prefix)

**Response (Verified):**
```json
{
  "verified": true,
  "hash": "0xa1b2c3d4e5f6...",
  "issuerId": "1",
  "owner": "0x1234...",
  "timestamp": "1706352000",
  "isValid": true
}
```

**Response (Not Verified):**
```json
{
  "verified": false,
  "hash": "0xa1b2c3d4e5f6...",
  "message": "Document not found or not verified"
}
```

---

### Get Issuer

#### `GET /api/issuer/:id`

Get issuer information.

**Parameters:**
- `id`: Issuer ID

**Response:**
```json
{
  "issuerId": "1",
  "name": "Test University",
  "metadataURI": "ipfs://QmZxxx...",
  "isVerified": true,
  "registeredAt": "1706352000"
}
```

---

### Store Document (Informational)

#### `POST /api/store`

Get information about storing a document (actual storage happens on-chain via frontend).

**Request:**
```json
{
  "hash": "0xa1b2c3d4e5f6...",
  "issuerId": "1"
}
```

**Response:**
```json
{
  "message": "Use frontend to store document hash on-chain",
  "hash": "0xa1b2c3d4e5f6...",
  "issuerId": "1",
  "verifyCoreAddress": "0x..."
}
```

---

## Error Responses

All endpoints may return error responses in the following format:

```json
{
  "error": "Error message description"
}
```

**Status Codes:**
- `400`: Bad Request
- `500`: Internal Server Error

---

## Rate Limiting

API rate limiting may be implemented in production. Check response headers for rate limit information.

---

## Authentication

Currently, the API does not require authentication. Future versions may implement API keys for rate limiting and access control.

