// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
import "./ICitizenChecker.sol";
import "./SocialContract.sol";

contract CitizenshipChecker is ICitizenshipChecker {
    address public root;
    SocialContract public sc;

    function isCitizen(address _who, bytes memory _proof) external view returns (bool) {
        // Good enough for now
        address opco = toAddress(_proof);
        require(toBool(sc.attestations(sc, opco, keccak256("op.opco"))) == true);
        require(toBool(sc.attestations(opco, _who, keccak256("op.opco.citizen"))) == true);
        return true;
    }
}
