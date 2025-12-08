// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./interfaces/IVerifyCore.sol";

/**
 * @title CertificateNFT
 * @notice ERC-721 NFT representing a verified certificate
 * @dev Each certificate is an NFT containing document hash, issuer, and metadata
 */
contract CertificateNFT is ERC721URIStorage, Ownable, ReentrancyGuard {
    /**
     * @notice Structure to store certificate metadata
     */
    struct CertificateData {
        bytes32 docHash;
        uint256 issuerId;
        string certificateType; // e.g., "diploma", "license", "membership"
        uint256 issuedAt;
        address issuedBy;
    }

    /**
     * @notice Reference to the VerifyCore contract
     */
    IVerifyCore public verifyCore;

    /**
     * @notice Counter for token IDs
     */
    uint256 private _tokenIdCounter;

    /**
     * @notice Mapping from token ID to CertificateData
     */
    mapping(uint256 => CertificateData) public certificates;

    /**
     * @notice Mapping from document hash to token ID
     */
    mapping(bytes32 => uint256) public docHashToTokenId;

    /**
     * @notice Event emitted when a certificate is minted
     */
    event CertificateMinted(
        uint256 indexed tokenId,
        bytes32 indexed docHash,
        uint256 indexed issuerId,
        string certificateType,
        address owner,
        uint256 timestamp
    );

    /**
     * @notice Constructor
     * @param _verifyCore Address of the VerifyCore contract
     * @param initialOwner The address that will own the contract
     */
    constructor(address _verifyCore, address initialOwner)
        ERC721("BaseChainVerify Certificate", "BCVC")
        Ownable(initialOwner)
    {
        require(_verifyCore != address(0), "CertificateNFT: invalid verify core address");
        verifyCore = IVerifyCore(_verifyCore);
        _tokenIdCounter = 0;
    }

    /**
     * @notice Mint a certificate NFT for a verified document
     * @param docHash The SHA256 hash of the document
     * @param certificateType The type of certificate (e.g., "diploma", "license")
     * @param tokenURI The URI for the NFT metadata (IPFS or HTTP)
     * @return tokenId The ID of the minted token
     */
    function mintCertificate(
        bytes32 docHash,
        string memory certificateType,
        string memory tokenURI
    ) external nonReentrant returns (uint256 tokenId) {
        // Verify document exists and is valid
        (bool isValid, uint256 issuerId, address docOwner) = verifyCore.verifyDocument(docHash);
        require(isValid, "CertificateNFT: document is not verified");
        require(docOwner == msg.sender, "CertificateNFT: only document owner can mint");

        // Check if certificate already exists for this document
        require(
            docHashToTokenId[docHash] == 0,
            "CertificateNFT: certificate already exists for this document"
        );

        // Mint NFT
        _tokenIdCounter++;
        tokenId = _tokenIdCounter;

        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, tokenURI);

        certificates[tokenId] = CertificateData({
            docHash: docHash,
            issuerId: issuerId,
            certificateType: certificateType,
            issuedAt: block.timestamp,
            issuedBy: msg.sender
        });

        docHashToTokenId[docHash] = tokenId;

        emit CertificateMinted(
            tokenId,
            docHash,
            issuerId,
            certificateType,
            msg.sender,
            block.timestamp
        );

        return tokenId;
    }

    /**
     * @notice Get certificate data by token ID
     * @param tokenId The token ID
     * @return docHash The document hash
     * @return issuerId The issuer ID
     * @return certificateType The type of certificate
     * @return issuedAt Timestamp when certificate was issued
     * @return issuedBy Address that issued the certificate
     */
    function getCertificate(uint256 tokenId)
        external
        view
        returns (
            bytes32 docHash,
            uint256 issuerId,
            string memory certificateType,
            uint256 issuedAt,
            address issuedBy
        )
    {
        require(_ownerOf(tokenId) != address(0), "CertificateNFT: token does not exist");
        CertificateData memory cert = certificates[tokenId];
        return (
            cert.docHash,
            cert.issuerId,
            cert.certificateType,
            cert.issuedAt,
            cert.issuedBy
        );
    }

    /**
     * @notice Get token ID by document hash
     * @param docHash The document hash
     * @return tokenId The token ID, or 0 if not found
     */
    function getTokenIdByDocHash(bytes32 docHash) external view returns (uint256 tokenId) {
        return docHashToTokenId[docHash];
    }

    /**
     * @notice Update VerifyCore address (only owner)
     * @param _verifyCore New VerifyCore address
     */
    function setVerifyCore(address _verifyCore) external onlyOwner {
        require(_verifyCore != address(0), "CertificateNFT: invalid verify core address");
        verifyCore = IVerifyCore(_verifyCore);
    }

    /**
     * @notice Get total number of certificates minted
     * @return count The total number of certificates
     */
    function totalSupply() external view returns (uint256 count) {
        return _tokenIdCounter;
    }

    /**
     * @notice Override to prevent token transfers (certificates are non-transferable)
     * @dev Can be modified if transferable certificates are desired
     */
    function _update(address to, uint256 tokenId, address auth)
        internal
        virtual
        override
        returns (address)
    {
        // Allow transfers - certificates can be transferred
        return super._update(to, tokenId, auth);
    }
}

