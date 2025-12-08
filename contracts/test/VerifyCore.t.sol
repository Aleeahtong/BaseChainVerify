// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {IssuerRegistry} from "../src/IssuerRegistry.sol";
import {VerifyCore} from "../src/VerifyCore.sol";

contract VerifyCoreTest is Test {
    IssuerRegistry public issuerRegistry;
    VerifyCore public verifyCore;

    address public owner = address(1);
    address public issuer = address(2);
    address public user = address(3);

    bytes32 public constant TEST_DOC_HASH = keccak256("test-document");

    function setUp() public {
        vm.startPrank(owner);
        issuerRegistry = new IssuerRegistry(owner);
        verifyCore = new VerifyCore(address(issuerRegistry), owner);
        vm.stopPrank();
    }

    function test_StoreDocumentHash() public {
        // Register issuer
        vm.startPrank(issuer);
        uint256 issuerId = issuerRegistry.registerIssuer("Test University", "ipfs://test");
        vm.stopPrank();

        // Store document
        vm.startPrank(user);
        bool success = verifyCore.storeDocumentHash(TEST_DOC_HASH, issuerId);
        assertTrue(success);
        vm.stopPrank();

        // Verify document
        (bool isValid, uint256 returnedIssuerId, address docOwner) =
            verifyCore.verifyDocument(TEST_DOC_HASH);
        assertTrue(isValid);
        assertEq(returnedIssuerId, issuerId);
        assertEq(docOwner, user);
    }

    function test_RevertIf_DocumentHashIsZero() public {
        vm.startPrank(issuer);
        uint256 issuerId = issuerRegistry.registerIssuer("Test University", "ipfs://test");
        vm.stopPrank();

        vm.startPrank(user);
        vm.expectRevert("VerifyCore: docHash cannot be zero");
        verifyCore.storeDocumentHash(bytes32(0), issuerId);
        vm.stopPrank();
    }

    function test_RevertIf_IssuerNotVerified() public {
        vm.startPrank(user);
        vm.expectRevert("VerifyCore: issuer is not verified");
        verifyCore.storeDocumentHash(TEST_DOC_HASH, 999);
        vm.stopPrank();
    }

    function test_RevertIf_DocumentAlreadyExists() public {
        vm.startPrank(issuer);
        uint256 issuerId = issuerRegistry.registerIssuer("Test University", "ipfs://test");
        vm.stopPrank();

        vm.startPrank(user);
        verifyCore.storeDocumentHash(TEST_DOC_HASH, issuerId);
        vm.expectRevert("VerifyCore: document already exists");
        verifyCore.storeDocumentHash(TEST_DOC_HASH, issuerId);
        vm.stopPrank();
    }

    function test_GetDocumentMetadata() public {
        vm.startPrank(issuer);
        uint256 issuerId = issuerRegistry.registerIssuer("Test University", "ipfs://test");
        vm.stopPrank();

        vm.startPrank(user);
        verifyCore.storeDocumentHash(TEST_DOC_HASH, issuerId);
        vm.stopPrank();

        (uint256 returnedIssuerId, address docOwner, uint256 timestamp, bool isVerified) =
            verifyCore.getDocumentMetadata(TEST_DOC_HASH);

        assertEq(returnedIssuerId, issuerId);
        assertEq(docOwner, user);
        assertGt(timestamp, 0);
        assertTrue(isVerified);
    }

    function test_GetDocumentsByOwner() public {
        vm.startPrank(issuer);
        uint256 issuerId = issuerRegistry.registerIssuer("Test University", "ipfs://test");
        vm.stopPrank();

        bytes32 docHash1 = keccak256("doc1");
        bytes32 docHash2 = keccak256("doc2");

        vm.startPrank(user);
        verifyCore.storeDocumentHash(docHash1, issuerId);
        verifyCore.storeDocumentHash(docHash2, issuerId);
        vm.stopPrank();

        bytes32[] memory docs = verifyCore.getDocumentsByOwner(user);
        assertEq(docs.length, 2);
        assertEq(docs[0], docHash1);
        assertEq(docs[1], docHash2);
    }
}

