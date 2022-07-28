// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { SafeTransferLib } from "@rari-capital/solmate/src/utils/SafeTransferLib.sol";
import { ERC721 } from "@rari-capital/solmate/src/tokens/ERC721.sol";
import { IERC165 } from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Badge contract
 * @notice A minimalist soulbound ERC-721 Badge implementation
 * @author OPTIMISM + MOONSHOT COLLECTIVE
 */
contract Badge is ERC721, Ownable {
    /**
     * @notice adminContract address i.e BadgeAdmin address
     */
    address public adminContract;

    /**
     * @notice BaseURI of the NFT
     */
    string private baseURI;

    /**
     * @notice Total supply of the NFT
     */
    uint256 private totalSupply;

    /**
     * @notice Modifier to only allow adminContract i.e BadgeAdmin contract
     * to make certain function calls
     */
    modifier onlyAdmin() {
        require(msg.sender == adminContract, "Error: Sender is not Admin");
        _;
    }

    /**
     * @param _name Name of the NFT
     * @param _symbol Symbol of the NFT
     * @param _baseURI BaseURI of the NFT
     */
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseURI
    ) payable ERC721(_name, _symbol) {
        baseURI = _baseURI;
    }

    /**
     * @notice Mints the soulbound badge NFT.
     * @notice Only Admin contract i.e BadgeAdmin contract can mint the badge.
     *
     * @param _citizen Address of the citizen
     */
    function mint(address _citizen) external onlyAdmin {
        require(adminContract != address(0), "Badge: Admin Contract not set");
        _mint(_citizen, totalSupply++);
    }

    /**
     * @notice Burns the soulbound badge NFT.
     *
     * @param _id The token ID of the NFT
     */
    function burn(uint256 _id) external onlyAdmin {
        _burn(_id);
    }

    /**
     * @notice Updates the admin contract
     *
     * @param _adminContract Address of the admin contract
     */
    function updateAdminContract(address _adminContract) external onlyOwner {
        adminContract = _adminContract;
    }

    /**
     * @notice Withdraw the contract ETH balance
     */
    function withdraw() external onlyOwner {
        SafeTransferLib.safeTransferETH(msg.sender, address(this).balance);
    }

    /**
     * @notice Returns the the tokenURI for given NFT token ID.
     *
     * @param _id The token ID of the NFT
     */
    function tokenURI(uint256 _id) public view override returns (string memory) {
        return string(abi.encodePacked(baseURI, _id));
    }

    /**
     * @notice Make the Badge Soul Bound
     * @notice Override the ERC721 transferFrom method to revert
     */
    function transferFrom(
        address,
        address,
        uint256
    ) public pure override {
        revert("SOULBOUND");
    }

    /**
     * @notice Override the ERC721 Approve method to revert
     */
    function approve(address, uint256) public pure override {
        revert("SOULBOUND");
    }

    /**
     * @notice Override the ERC721 setApprovalForAll method to revert
     */
    function setApprovalForAll(address, bool) public pure override {
        revert("SOULBOUND");
    }

    /**
     * @notice ERC165 interface check function
     *
     * @param _interfaceId Interface ID to check
     *
     * @return Whether or not the interface is supported by this contract
     */
    function supportsInterface(bytes4 _interfaceId) public view override returns (bool) {
        bytes4 iface1 = type(IERC165).interfaceId;
        return _interfaceId == iface1;
    }
}
