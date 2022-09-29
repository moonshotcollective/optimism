// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./ICitizenChecker.sol";
import "./SocialContract.sol";

contract CitizenBadge is ERC721 {
    address public admin;

    constructor(address _admin) ERC721("CitizenBadge", "CB") {
        admin = _admin;
    }

    function mint(
        address _to,
        uint256 _tokenId,
        bytes memory _proof
    ) public {
        require(ICitizenshipChecker.isCitizen(_to, _proof));
        _mint(_to, _tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        revert("CitizenBagde: SOULBOUND");
    }

    function _baseURI() internal pure override returns (bytes) {
        return
            SocialContract.attestations[admin][address(this)][
                keccak256("opnft.citizenshipBadgeNftBaseURI")
            ];
    }
}
