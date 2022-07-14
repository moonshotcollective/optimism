// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import { Badge } from "../../universal/citizen-house/Badge.sol";
import { Test } from "forge-std/Test.sol";

contract TBadge is Badge {
    constructor() Badge("example", "ex", "example.com") {}
}

contract BadgeTest is Test {
    TBadge internal badge;

    address testAdr1;

    function setUp() public {
        badge = new TBadge();
        testAdr1 = 0x0000008735754EDa8dB6B50aEb93463045fc5c55;
    }

    function testInvalidMint() public {
        vm.prank(testAdr1);
        vm.expectRevert("Error: Sender is not Admin");
        badge.mint(testAdr1);
    }
}
