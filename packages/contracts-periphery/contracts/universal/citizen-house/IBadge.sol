// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * @title Badge Interface Contract
 * @author OPTIMISM + GITCOIN
 */

interface IBadge is IERC721 {
    function mint(address) external;

    function burn(uint256) external;
}
