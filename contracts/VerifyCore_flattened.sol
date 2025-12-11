// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// lib/openzeppelin-contracts/contracts/utils/Context.sol

// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// src/interfaces/IIssuerRegistry.sol

/**
 * @title IIssuerRegistry
 * @notice Interface for the issuer registry contract
 */
interface IIssuerRegistry {
    /**
     * @notice Register a new issuer organization
     * @param name The name of the issuer
     * @param metadataURI IPFS URI containing issuer metadata
     * @return issuerId The ID of the newly registered issuer
     */
    function registerIssuer(string memory name, string memory metadataURI)
        external
        returns (uint256 issuerId);

    /**
     * @notice Remove an issuer (only admin)
     * @param issuerId The ID of the issuer to remove
     */
    function removeIssuer(uint256 issuerId) external;

    /**
     * @notice Check if an issuer is verified
     * @param issuerId The ID of the issuer
     * @return isVerified Whether the issuer is verified
     */
    function isIssuerVerified(uint256 issuerId) external view returns (bool isVerified);

    /**
     * @notice Get issuer information
     * @param issuerId The ID of the issuer
     * @return name The name of the issuer
     * @return metadataURI The IPFS URI of issuer metadata
     * @return isVerified Whether the issuer is verified
     * @return registeredAt Timestamp when issuer was registered
     */
    function getIssuer(uint256 issuerId)
        external
        view
        returns (
            string memory name,
            string memory metadataURI,
            bool isVerified,
            uint256 registeredAt
        );
}

// src/interfaces/IVerifyCore.sol

/**
 * @title IVerifyCore
 * @notice Interface for the core verification contract
 */
interface IVerifyCore {
    /**
     * @notice Store a document hash on-chain
     * @param docHash The SHA256 hash of the document
     * @param issuerId The ID of the issuer organization
     * @return success Whether the operation was successful
     */
    function storeDocumentHash(bytes32 docHash, uint256 issuerId) external returns (bool);

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
        returns (bool isValid, uint256 issuerId, address owner);

    /**
     * @notice Get the owner of a document
     * @param docHash The SHA256 hash of the document
     * @return owner The address that owns the document
     */
    function getDocumentOwner(bytes32 docHash) external view returns (address owner);

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
        returns (
            uint256 issuerId,
            address owner,
            uint256 timestamp,
            bool isVerified
        );
}

// lib/openzeppelin-contracts/contracts/access/Ownable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// src/VerifyCore.sol

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

