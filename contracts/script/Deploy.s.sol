// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {IssuerRegistry} from "../src/IssuerRegistry.sol";
import {VerifyCore} from "../src/VerifyCore.sol";
import {CertificateNFT} from "../src/CertificateNFT.sol";

/**
 * @title DeployScript
 * @notice Script to deploy all BaseChainVerify contracts
 */
contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("Deploying BaseChainVerify contracts...");
        console.log("Deployer address:", deployer);
        console.log("Deployer balance:", deployer.balance);

        vm.startBroadcast(deployerPrivateKey);

        // 1. Deploy IssuerRegistry
        console.log("\n1. Deploying IssuerRegistry...");
        IssuerRegistry issuerRegistry = new IssuerRegistry(deployer);
        console.log("IssuerRegistry deployed at:", address(issuerRegistry));

        // 2. Deploy VerifyCore
        console.log("\n2. Deploying VerifyCore...");
        VerifyCore verifyCore = new VerifyCore(address(issuerRegistry), deployer);
        console.log("VerifyCore deployed at:", address(verifyCore));

        // 3. Deploy CertificateNFT
        console.log("\n3. Deploying CertificateNFT...");
        CertificateNFT certificateNFT = new CertificateNFT(address(verifyCore), deployer);
        console.log("CertificateNFT deployed at:", address(certificateNFT));

        vm.stopBroadcast();

        console.log("\n=== Deployment Summary ===");
        console.log("IssuerRegistry:", address(issuerRegistry));
        console.log("VerifyCore:", address(verifyCore));
        console.log("CertificateNFT:", address(certificateNFT));
        console.log("\nDeployment completed successfully!");
    }
}

