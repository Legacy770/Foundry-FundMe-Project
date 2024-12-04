//SPDX-License-Identifier: MIT
//1 Deploy mocks on local anvil chain
//2. keep track of contract addresses across different chains

pragma solidity ^0.8.18;
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    //If we are on a local chain, we deploy on mocks
    //otherwise we get exisiting address from the live network

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e18;
    struct NetworkConfig {
        address priceFeed; //ETH/USD price feed address
    }
    NetworkConfig public activeNetWorkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            //this figure is the chain id for sepolia test network
            activeNetWorkConfig = getSepoliaEthConfig();
        } else {
            activeNetWorkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
        //price feed address
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetWorkConfig.priceFeed != address(0)) {
            return activeNetWorkConfig;
        }
        //price feed address
        //1. Deploy the mocks
        //2. return the mock address
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();
        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilConfig;
    }
}
