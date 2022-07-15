// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import { SafeTransferLib } from "@rari-capital/solmate/src/utils/SafeTransferLib.sol";
import { ERC721 } from "@rari-capital/solmate/src/tokens/ERC721.sol";
import { IERC165 } from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

error Soulbound(string _method);

/// @notice A minimalist soulbound ERC-721 Badge implementaion
/// @author OPTIMISM + MOONSHOT COLLECTIVE

contract Badge is ERC721, Ownable {
    event Minted(address indexed _minter, address indexed _opco);
    event Burned(address indexed _burner);

    modifier onlyAdmin() {
        require(msg.sender == AdminContract, "Error: Sender is not Admin");
        _;
    }

    address public AdminContract;
    string private baseURI;
    uint256 private totalSupply;

    /*///////////////////////////////////////////////////////////////
                            CONSTRUCTOR
  //////////////////////////////////////////////////////////////*/

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseURI
    ) payable ERC721(_name, _symbol) {
        baseURI = _baseURI;
    }

    /// @notice Mint
    /// @dev Mints the soulbound ERC721 token.
    function mint(address _citizen) external onlyAdmin {
        require(
            AdminContract != address(0),
            "Only Admin Contract can mint & Admin Contract not set"
        );
        _mint(_citizen, totalSupply++);
    }

    /// @notice Burn
    /// @dev Burns the soulbound ERC721.
    /// @param _id The token URI.
    function burn(uint256 _id) external {
        require(_ownerOf[_id] == msg.sender, "Error: Sender is not owner");
        _burn(_id);
    }

    /// @notice Token URI
    /// @dev Generate a token URI.
    /// @param _id The token URI.
    function tokenURI(uint256 _id) public view override returns (string memory) {
        return string(abi.encodePacked(baseURI, _id));
    }

    /// @notice AdminContract
    /// @dev Update Admin Contract
    function updateAdminContract(address _adminContract) external onlyOwner {
        AdminContract = _adminContract;
    }

    /// @notice Withdraw
    /// @dev Withdraw the contract ETH balance
    function withdraw() external onlyOwner {
        SafeTransferLib.safeTransferETH(msg.sender, address(this).balance);
    }

    /*///////////////////////////////////////////////////////////////
                            Make the Badge Soul Bound
  //////////////////////////////////////////////////////////////*/

    /// @notice Transfer ERC721
    /// @dev Override the ERC721 transferFrom method to revert
    function transferFrom(
        address,
        address,
        uint256
    ) public pure override {
        // Make it ~*~ Soulbound ~*~
        revert Soulbound("transferFrom(address, address, uint256)");
    }

    /// @notice Approve ERC721
    /// @dev Override the ERC721 Approve method to revert
    function approve(address, uint256) public pure override {
        revert Soulbound("approve(address, uint256)");
    }

    /// @notice setApprovalForAll ERC721
    /// @dev Override the ERC721 setApprovalForAll method to revert
    function setApprovalForAll(address, bool) public pure override {
        revert Soulbound("setApprovalForAll(address, uint256)");
    }

    /// @notice ERC165 interface check function.
    /// @param _interfaceId Interface ID to check.
    /// @return Whether or not the interface is supported by this contract.
    function supportsInterface(bytes4 _interfaceId) public view override returns (bool) {
        bytes4 iface1 = type(IERC165).interfaceId;
        return _interfaceId == iface1;
    }
}
