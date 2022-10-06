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

    constructor(address _root, address _sc) {
        root = _root;
        sc = SocialContract(_sc);
    }

    function toBool(bytes memory _b) internal pure returns (bool) {
        return abi.decode(_b, (bool));
    }

    function toUint256(bytes memory _b) internal pure returns (uint256) {
        return abi.decode(_b, (uint256));
    }

    function isCitizen(address _who, bytes memory _proof) external view returns (bool) {
        CitizenProof memory proof = abi.decode(_proof, (CitizenProof));
        bytes memory numOpcoCitizenships = sc.attestations(root, proof.opco, keccak256("op.opco"));
        require(proof.index < toUint256(numOpcoCitizenships));
        require(
            toBool(
                sc.attestations(
                    proof.opco,
                    _who,
                    keccak256(abi.encodePacked("op.opco.citizen.", proof.index))
                )
            )
        );
        return true;
    }
}
