// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.9;

import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IBadge is IERC721 {
    function mint(address _citizen) external;

    function burn(uint256 id) external;
}
