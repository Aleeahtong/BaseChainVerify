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

// src/IssuerRegistry.sol

/**
 * @title IssuerRegistry
 * @notice Registry of verified organizations that can issue certificates
 * @dev Manages the list of trusted issuers (universities, companies, services)
 */
contract IssuerRegistry is IIssuerRegistry, Ownable {
    /**
     * @notice Structure to store issuer information
     */
    struct Issuer {
        string name;
        string metadataURI;
        bool isVerified;
        uint256 registeredAt;
        address registeredBy;
    }

    /**
     * @notice Counter for issuer IDs
     */
    uint256 private _issuerCounter;

    /**
     * @notice Mapping from issuer ID to Issuer struct
     */
    mapping(uint256 => Issuer) public issuers;

    /**
     * @notice Mapping from address to issuer ID (for quick lookup)
     */
    mapping(address => uint256) public addressToIssuerId;

    /**
     * @notice Event emitted when a new issuer is registered
     */
    event IssuerRegistered(
        uint256 indexed issuerId,
        string name,
        address indexed registeredBy,
        uint256 timestamp
    );

    /**
     * @notice Event emitted when an issuer is removed
     */
    event IssuerRemoved(uint256 indexed issuerId, address indexed removedBy, uint256 timestamp);

    /**
     * @notice Event emitted when an issuer verification status changes
     */
    event IssuerVerificationChanged(
        uint256 indexed issuerId,
        bool isVerified,
        address indexed changedBy
    );

    /**
     * @notice Constructor
     * @param initialOwner The address that will own the contract
     */
    constructor(address initialOwner) Ownable(initialOwner) {
        _issuerCounter = 0;
    }

    /**
     * @notice Register a new issuer organization
     * @param name The name of the issuer
     * @param metadataURI IPFS URI containing issuer metadata
     * @return issuerId The ID of the newly registered issuer
     */
    function registerIssuer(string memory name, string memory metadataURI)
        external
        override
        returns (uint256 issuerId)
    {
        require(bytes(name).length > 0, "IssuerRegistry: name cannot be empty");
        require(bytes(metadataURI).length > 0, "IssuerRegistry: metadataURI cannot be empty");
        require(
            addressToIssuerId[msg.sender] == 0 || !issuers[addressToIssuerId[msg.sender]].isVerified,
            "IssuerRegistry: address already registered as verified issuer"
        );

        _issuerCounter++;
        issuerId = _issuerCounter;

        issuers[issuerId] = Issuer({
            name: name,
            metadataURI: metadataURI,
            isVerified: true, // Auto-verified on registration (can be changed by admin)
            registeredAt: block.timestamp,
            registeredBy: msg.sender
        });

        addressToIssuerId[msg.sender] = issuerId;

        emit IssuerRegistered(issuerId, name, msg.sender, block.timestamp);

        return issuerId;
    }

    /**
     * @notice Remove an issuer (only admin)
     * @param issuerId The ID of the issuer to remove
     */
    function removeIssuer(uint256 issuerId) external override onlyOwner {
        require(issuers[issuerId].registeredAt > 0, "IssuerRegistry: issuer does not exist");

        issuers[issuerId].isVerified = false;

        emit IssuerRemoved(issuerId, msg.sender, block.timestamp);
    }

    /**
     * @notice Set verification status of an issuer (only admin)
     * @param issuerId The ID of the issuer
     * @param isVerified The new verification status
     */
    function setIssuerVerification(uint256 issuerId, bool isVerified) external onlyOwner {
        require(issuers[issuerId].registeredAt > 0, "IssuerRegistry: issuer does not exist");

        issuers[issuerId].isVerified = isVerified;

        emit IssuerVerificationChanged(issuerId, isVerified, msg.sender);
    }

    /**
     * @notice Check if an issuer is verified
     * @param issuerId The ID of the issuer
     * @return isVerified Whether the issuer is verified
     */
    function isIssuerVerified(uint256 issuerId) external view override returns (bool isVerified) {
        return issuers[issuerId].isVerified && issuers[issuerId].registeredAt > 0;
    }

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
        override
        returns (
            string memory name,
            string memory metadataURI,
            bool isVerified,
            uint256 registeredAt
        )
    {
        Issuer memory issuer = issuers[issuerId];
        require(issuer.registeredAt > 0, "IssuerRegistry: issuer does not exist");

        return (issuer.name, issuer.metadataURI, issuer.isVerified, issuer.registeredAt);
    }

    /**
     * @notice Get total number of issuers
     * @return count The total number of registered issuers
     */
    function getIssuerCount() external view returns (uint256 count) {
        return _issuerCounter;
    }
}

