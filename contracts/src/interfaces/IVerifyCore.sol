// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

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

