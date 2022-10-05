// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
import { Test } from "forge-std/Test.sol";
import { CitizenBadge } from "../../universal/optimist-nft/CitizenBadge.sol";

contract CitizenBadgeTest is Test {
    CitizenBadge cb;

    function setUp() public {
        cb = new CitizenBadge(address(this));
        vm.label(address(cb), "CitizenBadge");
    }

    function test_mint() external {
        bytes memory proof = hex"";
        cb.mint(address(this), 1, proof);
        assertEq(cb.ownerOf(1), address(this));
    }
}
