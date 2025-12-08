// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {IssuerRegistry} from "../src/IssuerRegistry.sol";

contract IssuerRegistryTest is Test {
    IssuerRegistry public issuerRegistry;

    address public owner = address(1);
    address public issuer = address(2);

    function setUp() public {
        vm.startPrank(owner);
        issuerRegistry = new IssuerRegistry(owner);
        vm.stopPrank();
    }

    function test_RegisterIssuer() public {
        vm.startPrank(issuer);
        uint256 issuerId = issuerRegistry.registerIssuer("Test University", "ipfs://test-metadata");
        vm.stopPrank();

        assertEq(issuerId, 1);
        assertTrue(issuerRegistry.isIssuerVerified(issuerId));

        (string memory name, string memory metadataURI, bool isVerified, uint256 registeredAt) =
            issuerRegistry.getIssuer(issuerId);

        assertEq(name, "Test University");
        assertEq(metadataURI, "ipfs://test-metadata");
        assertTrue(isVerified);
        assertGt(registeredAt, 0);
    }

    function test_RevertIf_EmptyName() public {
        vm.startPrank(issuer);
        vm.expectRevert("IssuerRegistry: name cannot be empty");
        issuerRegistry.registerIssuer("", "ipfs://test");
        vm.stopPrank();
    }

    function test_RevertIf_EmptyMetadataURI() public {
        vm.startPrank(issuer);
        vm.expectRevert("IssuerRegistry: metadataURI cannot be empty");
        issuerRegistry.registerIssuer("Test University", "");
        vm.stopPrank();
    }

    function test_RemoveIssuer() public {
        vm.startPrank(issuer);
        uint256 issuerId = issuerRegistry.registerIssuer("Test University", "ipfs://test");
        vm.stopPrank();

        assertTrue(issuerRegistry.isIssuerVerified(issuerId));

        vm.startPrank(owner);
        issuerRegistry.removeIssuer(issuerId);
        vm.stopPrank();

        assertFalse(issuerRegistry.isIssuerVerified(issuerId));
    }

    function test_SetIssuerVerification() public {
        vm.startPrank(issuer);
        uint256 issuerId = issuerRegistry.registerIssuer("Test University", "ipfs://test");
        vm.stopPrank();

        vm.startPrank(owner);
        issuerRegistry.setIssuerVerification(issuerId, false);
        assertFalse(issuerRegistry.isIssuerVerified(issuerId));

        issuerRegistry.setIssuerVerification(issuerId, true);
        assertTrue(issuerRegistry.isIssuerVerified(issuerId));
        vm.stopPrank();
    }

    function test_GetIssuerCount() public {
        address issuer1 = address(2);
        address issuer2 = address(3);
        
        vm.startPrank(issuer1);
        issuerRegistry.registerIssuer("University 1", "ipfs://1");
        vm.stopPrank();
        
        vm.startPrank(issuer2);
        issuerRegistry.registerIssuer("University 2", "ipfs://2");
        vm.stopPrank();

        assertEq(issuerRegistry.getIssuerCount(), 2);
    }
}

