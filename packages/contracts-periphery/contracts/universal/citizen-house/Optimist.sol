// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { SafeTransferLib } from "solmate/utils/SafeTransferLib.sol";
import { ERC721 } from "solmate/tokens/ERC721.sol";
import { IERC165 } from "openzeppelin-contracts/contracts/utils/introspection/IERC165.sol";
import { Ownable } from "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import { SocialContract } from "./SocialContract.sol";
import { MintManager } from "./MintManager.sol";

error Soulbound();

/**
 * @title Optimist contract
 * @notice Soulbound Optimism Profile NFT
 * @author OPTIMISM + GITCOIN
 */
contract Optimist is ERC721, Ownable {
    uint256 public totalSupply;
    string public baseURI;
    address public optimistNftAdmin;
    address public socialContract;
    address public mintManagerContract;

    constructor(
        string memory _name,
        string memory _symbol,
        address memory _optimistNftAdmin,
        address memory _socialContract,
        address memory _mintManager
    ) payable ERC721(_name, _symbol) {
        optimistNftAdmin = _optimistNftAdmin;
        socialContract = _socialContract;
        mintManager = _mintManager;
    }

    function updateBaseURI() public onlyOwner {
        bytes32 uri = keccak256("opnft.optimistNftBaseURI");
        baseURI = SocialContract(socialContract).attestations[optimistNftAdmin][address(this)][uri];
    }

    function updateAdminContracts(address _optimistNftAdmin, address _socialContract)
        public
        onlyOwner
    {
        optimistNftAdmin = _optimistNftAdmin;
        socialContract = _socialContract;
        bytes32 _mintManager = keccak256("opnft.mintManagerAddress");
        mintManager = SocialContract(socialContract).attestations[optimistNftAdmin][address(this)][
            _mintManager
        ];
    }

    function mint() external payable {
        require(balanceOf(msg.sender) == 0, "Optimist: AlreadyClaimed");
        require(
            MintManager(mintManager).canAddressMint(msg.sender) == true,
            "Optimist: InvalidMinter"
        );
        unchecked {
            _mint(msg.sender, totalSupply++);
        }
    }

    function burn(uint256 _id) external {
        require(balanceOf(msg.sender) == 1 || ownerOf(_id) == msg.sender, "Optimist: InvalidBurn");
        unchecked {
            _burn(_id);
        }
    }

    function withdraw() external onlyOwner {
        SafeTransferLib.safeTransferETH(msg.sender, address(this).balance);
    }

    function tokenURI(uint256 _id) public view override returns (string memory) {
        require(msg.sender != address(0), "Optimist: DoesNotExist");
        return string(abi.encodePacked(baseURI, _id));
    }

    // Make it ~*~ Souldbound ~*~
    function transferFrom(
        address,
        address,
        uint256
    ) public pure override {
        revert Soulbound();
    }

    function supportsInterface(bytes4 _interfaceId) public pure override returns (bool) {
        bytes4 iface1 = type(IERC165).interfaceId;
        return _interfaceId == iface1;
    }
}
