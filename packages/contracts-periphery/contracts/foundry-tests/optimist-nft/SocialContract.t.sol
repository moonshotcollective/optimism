// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

// import { Badge } from "../../universal/citizen-house/Badge.sol";
import { Test } from "forge-std/Test.sol";
import { SocialContract } from "../../universal/optimist-nft/SocialContract.sol";

contract SocialContractTest is Test {
    SocialContract sc;

    function setUp() public {
        sc = new SocialContract();
        vm.label(address(sc), "SocialContract");
    }

    function test_attest() external {
        bytes memory proof = hex"";
        sc.attest(address(this), keccak256("opnft.citizenshipBadgeNftBaseURI"), proof);
        assertEq(
            sc.attestations(
                address(this),
                address(this),
                keccak256("opnft.citizenshipBadgeNftBaseURI")
            ),
            proof
        );
    }
}
