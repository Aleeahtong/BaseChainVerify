// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IIssuerRegistry.sol";

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

