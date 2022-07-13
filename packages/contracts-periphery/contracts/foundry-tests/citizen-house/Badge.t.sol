// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { Badge } from "../../universal/citizen-house/Badge.sol";
import { Test } from "forge-std/Test.sol";

contract TBadge is Badge {
    constructor() Badge("example", "ex", "example.com") {}
}

contract BadgeTest is Test {
    TBadge internal badge;

    address testAdr1 = makeAddr("admin");

    function setUp() public {
        badge = new TBadge();
    }

    function testInvalidMint() public {
        vm.prank(testAdr1);
        vm.expectRevert("Badge: Sender is not Admin");
        badge.mint(testAdr1);
    }

    function testInvalidBurn() public {
        vm.prank(testAdr1);
        vm.expectRevert("Badge: Sender is not Admin");
        badge.burn(0);
    }
}
