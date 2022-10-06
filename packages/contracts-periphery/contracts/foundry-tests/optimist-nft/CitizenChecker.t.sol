// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
import { Test } from "forge-std/Test.sol";
import { CitizenChecker } from "../../universal/optimist-nft/CitizenChecker.sol";
import { SocialContract } from "../../universal/optimist-nft/SocialContract.sol";

contract CitizenCheckerTest is Test {
    CitizenChecker cc;
    SocialContract sc;

    function setUp() public {
        sc = new SocialContract();
        cc = new CitizenChecker(address(this), address(sc));
        vm.label(address(cc), "CitizenChecker");
        vm.label(address(sc), "SocialContract");

        SocialContract.AttestationData[] memory attestations = new SocialContract.AttestationData[](
            1
        );
        attestations[0] = SocialContract.AttestationData({
            about: address(this),
            key: keccak256("op.opco.citizen"),
            val: abi.encode(address(this))
        });
        sc.attest(attestations);
    }

    function test_isCitizen() external {
        bytes memory proof = abi.encode(
            CitizenChecker.CitizenProof({ opco: address(this), index: 0 })
        );
        assertEq(cc.isCitizen(address(this), proof), true);
    }
}
