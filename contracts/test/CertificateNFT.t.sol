// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {IssuerRegistry} from "../src/IssuerRegistry.sol";
import {VerifyCore} from "../src/VerifyCore.sol";
import {CertificateNFT} from "../src/CertificateNFT.sol";

contract CertificateNFTTest is Test {
    IssuerRegistry public issuerRegistry;
    VerifyCore public verifyCore;
    CertificateNFT public certificateNFT;

    address public owner = address(1);
    address public issuer = address(2);
    address public user = address(3);

    bytes32 public constant TEST_DOC_HASH = keccak256("test-document");

    function setUp() public {
        vm.startPrank(owner);
        issuerRegistry = new IssuerRegistry(owner);
        verifyCore = new VerifyCore(address(issuerRegistry), owner);
        certificateNFT = new CertificateNFT(address(verifyCore), owner);
        vm.stopPrank();
    }

    function test_MintCertificate() public {
        // Register issuer
        vm.startPrank(issuer);
        uint256 issuerId = issuerRegistry.registerIssuer("Test University", "ipfs://test");
        vm.stopPrank();

        // Store document
        vm.startPrank(user);
        verifyCore.storeDocumentHash(TEST_DOC_HASH, issuerId);
        vm.stopPrank();

        // Mint certificate
        vm.startPrank(user);
        uint256 tokenId = certificateNFT.mintCertificate(
            TEST_DOC_HASH, "diploma", "ipfs://certificate-metadata"
        );
        vm.stopPrank();

        assertEq(certificateNFT.ownerOf(tokenId), user);
        assertEq(certificateNFT.getTokenIdByDocHash(TEST_DOC_HASH), tokenId);

        (
            bytes32 docHash,
            uint256 returnedIssuerId,
            string memory certType,
            uint256 issuedAt,
            address issuedBy
        ) = certificateNFT.getCertificate(tokenId);

        assertEq(docHash, TEST_DOC_HASH);
        assertEq(returnedIssuerId, issuerId);
        assertEq(certType, "diploma");
        assertGt(issuedAt, 0);
        assertEq(issuedBy, user);
    }

    function test_RevertIf_DocumentNotVerified() public {
        vm.startPrank(user);
        vm.expectRevert("CertificateNFT: document is not verified");
        certificateNFT.mintCertificate(TEST_DOC_HASH, "diploma", "ipfs://metadata");
        vm.stopPrank();
    }

    function test_RevertIf_NotDocumentOwner() public {
        vm.startPrank(issuer);
        uint256 issuerId = issuerRegistry.registerIssuer("Test University", "ipfs://test");
        vm.stopPrank();

        vm.startPrank(user);
        verifyCore.storeDocumentHash(TEST_DOC_HASH, issuerId);
        vm.stopPrank();

        vm.startPrank(address(4)); // Different user
        vm.expectRevert("CertificateNFT: only document owner can mint");
        certificateNFT.mintCertificate(TEST_DOC_HASH, "diploma", "ipfs://metadata");
        vm.stopPrank();
    }

    function test_RevertIf_CertificateAlreadyExists() public {
        vm.startPrank(issuer);
        uint256 issuerId = issuerRegistry.registerIssuer("Test University", "ipfs://test");
        vm.stopPrank();

        vm.startPrank(user);
        verifyCore.storeDocumentHash(TEST_DOC_HASH, issuerId);
        certificateNFT.mintCertificate(TEST_DOC_HASH, "diploma", "ipfs://metadata");

        vm.expectRevert("CertificateNFT: certificate already exists for this document");
        certificateNFT.mintCertificate(TEST_DOC_HASH, "diploma", "ipfs://metadata");
        vm.stopPrank();
    }

    function test_TotalSupply() public {
        vm.startPrank(issuer);
        uint256 issuerId = issuerRegistry.registerIssuer("Test University", "ipfs://test");
        vm.stopPrank();

        bytes32 docHash1 = keccak256("doc1");
        bytes32 docHash2 = keccak256("doc2");

        vm.startPrank(user);
        verifyCore.storeDocumentHash(docHash1, issuerId);
        verifyCore.storeDocumentHash(docHash2, issuerId);

        certificateNFT.mintCertificate(docHash1, "diploma", "ipfs://1");
        certificateNFT.mintCertificate(docHash2, "license", "ipfs://2");
        vm.stopPrank();

        assertEq(certificateNFT.totalSupply(), 2);
    }
}

