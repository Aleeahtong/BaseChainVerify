// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

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

