// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./ICitizenChecker.sol";
import "./SocialContract.sol";

contract CitizenBadge is ERC721 {
    address public admin;

    SocialContract public sc;

    constructor(address _admin) ERC721("CitizenBadge", "CB") {
        admin = _admin;
    }

    function mint(
        address _to,
        uint256 _tokenId,
        bytes memory _proof
    ) public {
        // check if the user is a citizen
        require(ICitizenChecker(admin).isCitizen(_to, _proof), "CitizenBadge: not a citizen");
        _mint(_to, _tokenId);
    }

    function _transfer(
        address,
        address,
        uint256
    ) internal pure override {
        revert("CitizenBagde: SOULBOUND");
    }

    function _baseURI() internal view override returns (string memory) {
        return
            abi.decode(
                sc.attestations(
                    admin,
                    address(this),
                    keccak256("opnft.citizenshipBadgeNftBaseURI")
                ),
                (string)
            );
    }
}
