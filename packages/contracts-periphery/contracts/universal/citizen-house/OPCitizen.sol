// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { SafeTransferLib } from "@rari-capital/solmate/utils/SafeTransferLib.sol";
import { ERC721 } from "@rari-capital/solmate/tokens/ERC721.sol";
import { IERC165 } from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

error InvalidMinter();
error Soulbound();
error AlreadyClaimed();
error InvalidBurn();
error DoesNotExist();

/**
 * @title OPCitizen contract
 * @notice Soulbound Optimism Citizenship NFT
 * @author OPTIMISM + GITCOIN
 */
contract OPCitizen is ERC721, Ownable {
    /**
     * @notice Total Supply of the NFT.
     */
    uint256 public totalSupply;
    string public baseURI;
    bytes32 public citizenRoot;
    uint256 immutable maxInvites;

    /**
     * @notice Numnber of invites available for a given citizen
     */
    mapping(address => uint256) public inviteCount;
    mapping(address => bool) public hasInvite;

    /**
     * @param _name Name of the NFT
     * @param _symbol Symbol of the NFT
     * @param _baseURI BaseURI of the NFT
     * @param _maxInvites Max inivtes per citizen
     */
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseURI,
        uint256 _maxInvites
    ) payable ERC721(_name, _symbol) {
        baseURI = _baseURI;
        maxInvites = _maxInvites;
    }

    function updateCitizenRoot(bytes32 _citizenRoot) public onlyOwner {
        citizenRoot = _citizenRoot;
    }

    function mintCitizenship(bytes32[] calldata _proof) external payable {
        if (balanceOf(msg.sender) > 0) revert AlreadyClaimed();
        if (!_verify(_proof, citizenRoot, _leaf(msg.sender))) revert InvalidMinter();
        unchecked {
            _mint(msg.sender, totalSupply++);
        }
        inviteCount[msg.sender] = maxInvites;
    }

    function burn(uint256 _id) external {
        if (balanceOf(msg.sender) != 1 || ownerOf(_id) != msg.sender) revert InvalidBurn();
        unchecked {
            _burn(_id);
        }
        inviteCount[msg.sender] = 0;
    }

    function inviteCitizens(address[] calldata _adrs) external {
        require(
            inviteCount[msg.sender] > 0 && inviteCount[msg.sender] >= _adrs.length,
            "OPCitizen: Invalid invite request"
        );
        for (uint256 i = 0; i < _adrs.length; i++) {
            hasInvite[_adrs[i]] = true;
        }
    }

    function mintCitizenship() external payable {
        if (balanceOf(msg.sender) > 0) revert AlreadyClaimed();
        require(hasInvite[msg.sender] == true, "OPCitizen: Invalid mint request");
        unchecked {
            _mint(msg.sender, totalSupply++);
        }
    }

    function withdraw() external onlyOwner {
        SafeTransferLib.safeTransferETH(msg.sender, address(this).balance);
    }

    function tokenURI(uint256 _id) public view override returns (string memory) {
        if (msg.sender == address(0)) revert DoesNotExist();
        return string(abi.encodePacked(baseURI, _id));
    }

    function _leaf(address _adr) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_adr));
    }

    function _verify(
        bytes32[] memory _proof,
        bytes32 _root,
        bytes32 _node
    ) internal pure returns (bool) {
        return MerkleProof.verify(_proof, _root, _node);
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
