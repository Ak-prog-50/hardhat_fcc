// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {VRFCoordinatorV2TestHelper as Helper} from "@chainlink/contracts/src/v0.8/tests/VRFCoordinatorV2TestHelper.sol";

contract VRFCoordinatorV2TestHelper is Helper {
    constructor(
        address link,
        address blockhashStore,
        address linkEthFeed
    ) Helper(link, blockhashStore, linkEthFeed) {}
}