// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
import "./ICitizenChecker.sol";
import "./SocialContract.sol";

contract CitizenChecker is ICitizenChecker {
    struct CitizenProof {
        address opco;
        uint256 index;
    }

    address public root;
    SocialContract public sc;

    function isCitizen(address _who, bytes memory _proof) external view returns (bool) {
        CitizenProof memory proof = abi.decode(_proof, (CitizenProof));
        bytes memory numOpcoCitizenships = sc.attestations(root, proof.opco, keccak256("op.opco"));
        require(proof.index < uint256(bytes32(numOpcoCitizenships)));
        // require(
        //     sc.attestations(
        //         proof.opco,
        //         _who,
        //         keccak256(abi.encodePacked("op.opco.citizen.", proof.index))
        //     ) == true // TODO: fix this
        // );
        return true;
    }
}
