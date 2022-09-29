// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface ICitizenshipChecker {
    function isCitizen(address _who, bytes memory _proof) external view returns (bool);
}
