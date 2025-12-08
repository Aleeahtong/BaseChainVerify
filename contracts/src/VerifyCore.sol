// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IVerifyCore.sol";
import "./interfaces/IIssuerRegistry.sol";

/**
 * @title VerifyCore
 * @notice Core contract for storing and verifying document hashes on-chain
 * @dev Documents are stored as SHA256 hashes, not the actual documents
 */
contract VerifyCore is IVerifyCore, Ownable {
    /**
     * @notice Structure to store document information
     */
    struct Document {
        bytes32 docHash;
        uint256 issuerId;
        address owner;
        uint256 timestamp;
        bool isVerified;
    }

    /**
     * @notice Reference to the IssuerRegistry contract
     */
    IIssuerRegistry public issuerRegistry;

    /**
     * @notice Mapping from document hash to Document struct
     */
    mapping(bytes32 => Document) public documents;

    /**
     * @notice Mapping from owner address to array of document hashes
     */
    mapping(address => bytes32[]) public ownerDocuments;

    /**
     * @notice Event emitted when a document is stored
     */
    event DocumentStored(
        address indexed owner,
        bytes32 indexed docHash,
        uint256 indexed issuerId,
        uint256 timestamp
    );

    /**
     * @notice Event emitted when a document is verified
     */
    event DocumentVerified(
        bytes32 indexed docHash,
        uint256 indexed issuerId,
        bool result,
        address indexed verifier,
        uint256 timestamp
    );

    /**
     * @notice Constructor
     * @param _issuerRegistry Address of the IssuerRegistry contract
     * @param initialOwner The address that will own the contract
     */
    constructor(address _issuerRegistry, address initialOwner) Ownable(initialOwner) {
        require(_issuerRegistry != address(0), "VerifyCore: invalid issuer registry address");
        issuerRegistry = IIssuerRegistry(_issuerRegistry);
    }

    /**
     * @notice Store a document hash on-chain
     * @param docHash The SHA256 hash of the document
     * @param issuerId The ID of the issuer organization
     * @return success Whether the operation was successful
     */
    function storeDocumentHash(bytes32 docHash, uint256 issuerId)
        external
        override
        returns (bool success)
    {
        require(docHash != bytes32(0), "VerifyCore: docHash cannot be zero");
        require(
            issuerRegistry.isIssuerVerified(issuerId),
            "VerifyCore: issuer is not verified"
        );
        require(
            documents[docHash].timestamp == 0,
            "VerifyCore: document already exists"
        );

        documents[docHash] = Document({
            docHash: docHash,
            issuerId: issuerId,
            owner: msg.sender,
            timestamp: block.timestamp,
            isVerified: true
        });

        ownerDocuments[msg.sender].push(docHash);

        emit DocumentStored(msg.sender, docHash, issuerId, block.timestamp);

        return true;
    }

    /**
     * @notice Verify if a document hash exists and is valid
     * @param docHash The SHA256 hash of the document to verify
     * @return isValid Whether the document is verified
     * @return issuerId The ID of the issuer
     * @return owner The address that owns the document
     */
    function verifyDocument(bytes32 docHash)
        external
        view
        override
        returns (bool isValid, uint256 issuerId, address owner)
    {
        Document memory doc = documents[docHash];

        if (doc.timestamp == 0) {
            return (false, 0, address(0));
        }

        // Check if issuer is still verified
        bool issuerVerified = issuerRegistry.isIssuerVerified(doc.issuerId);

        isValid = doc.isVerified && issuerVerified;
        issuerId = doc.issuerId;
        owner = doc.owner;
    }

    /**
     * @notice Get the owner of a document
     * @param docHash The SHA256 hash of the document
     * @return owner The address that owns the document
     */
    function getDocumentOwner(bytes32 docHash) external view override returns (address owner) {
        require(documents[docHash].timestamp > 0, "VerifyCore: document does not exist");
        return documents[docHash].owner;
    }

    /**
     * @notice Get document metadata
     * @param docHash The SHA256 hash of the document
     * @return issuerId The ID of the issuer
     * @return owner The address that owns the document
     * @return timestamp When the document was stored
     * @return isVerified Whether the document is verified
     */
    function getDocumentMetadata(bytes32 docHash)
        external
        view
        override
        returns (
            uint256 issuerId,
            address owner,
            uint256 timestamp,
            bool isVerified
        )
    {
        Document memory doc = documents[docHash];
        require(doc.timestamp > 0, "VerifyCore: document does not exist");

        bool issuerVerified = issuerRegistry.isIssuerVerified(doc.issuerId);

        return (doc.issuerId, doc.owner, doc.timestamp, doc.isVerified && issuerVerified);
    }

    /**
     * @notice Get all document hashes owned by an address
     * @param owner The address to query
     * @return docHashes Array of document hashes
     */
    function getDocumentsByOwner(address owner) external view returns (bytes32[] memory docHashes) {
        return ownerDocuments[owner];
    }

    /**
     * @notice Get document count for an owner
     * @param owner The address to query
     * @return count The number of documents owned
     */
    function getDocumentCount(address owner) external view returns (uint256 count) {
        return ownerDocuments[owner].length;
    }

    /**
     * @notice Update issuer registry address (only owner)
     * @param _issuerRegistry New issuer registry address
     */
    function setIssuerRegistry(address _issuerRegistry) external onlyOwner {
        require(_issuerRegistry != address(0), "VerifyCore: invalid issuer registry address");
        issuerRegistry = IIssuerRegistry(_issuerRegistry);
    }
}

