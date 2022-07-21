// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { IBadge } from "./IBadge.sol";

/**
 * @notice Reverts with an AlreadyOPCO error
 *
 * @param _opco opco address
 */
error AlreadyOPCO(address _opco);

/**
 * @notice Reverts with an AlreadyCitizen error
 *
 * @param _citizen citizen address
 */
error AlreadyCitizen(address _citizen);

/**
 * @notice Reverts with a ExceedsCitizenSupply error
 *
 * @param _supply citizen supply
 */
error ExceedsCitizenSupply(uint256 _supply);

/**
 * @title BadgeAdmin contract
 * @notice An admin contract which controls who can mint the soulbound citizenship badges
 * @author OPTIMISM + MOONSHOT COLLECTIVE
 */
contract BadgeAdmin is Ownable {
    /**
     * @notice struct to store data of an OP
     */
    struct OP {
        address op;
        bytes32 metadata;
    }

    /**
     * @notice struct to store data of an OPCO
     */
    struct OPCO {
        address co;
        bool valid;
        address[] citizens;
        uint256 supply;
        uint256 minted;
        bytes32 metadata;
    }

    /**
     * @notice struct to store data of a Citizen
     */
    struct Citizen {
        address citizen;
        bool valid;
        bool minted;
        address opco;
        bytes ballot;
        address delegate;
        uint256 power;
        bytes32 metadata;
    }

    /**
     * @notice Total count of citizens added
     */
    uint256 public citizenCount;

    /**
     * @notice Total count of opcos added
     */
    uint256 public opcoCount;

    /**
     * @notice Maximum ops that can be added in a single transaction
     */
    uint256 public maxOPLimit;

    /**
     * @notice Maximum opcos that can be added in a single transaction
     */
    uint256 public maxOPCOLimit;

    /**
     * @notice Maximum citizens that can be added in a single transaction
     */
    uint256 public maxCitizenLimit;

    /**
     * @notice Array of OP structs
     */
    OP[] internal ops;

    /**
     * @notice Array of OPCO structs
     */
    OPCO[] internal opcos;

    /**
     * @notice Array of Citizen structs
     */
    Citizen[] internal citizens;

    /**
     * @notice Address of the Badge Contract
     */
    address public badgeContract;

    /**
     * @notice Mapping to store index of a given OP address in the ops Array
     */
    mapping(address => uint256) internal opIndex;

    /**
     * @notice Mapping to store index of a given OPCO address in the opcos Array
     */
    mapping(address => uint256) internal opcoIndex;

    /**
     * @notice Mapping to store index of a given citizen address in the citizens Array
     */
    mapping(address => uint256) internal citizenIndex;

    /**
     * @notice Emitted when ops are added
     *
     * @param _sender Address of the sender
     */
    event OPsAdded(address indexed _sender);

    /**
     * @notice Emitted when opcos are added
     *
     * @param _op OP address
     * @param _lastCursor Last index of the OPCO array
     */
    event OPCOsAdded(address indexed _op, uint256 indexed _lastCursor);

    /**
     * @notice Emitted when citizens are added
     *
     * @param _opco OPCO address
     * @param _lastCursor Last index of the Citizen array
     */
    event CitizensAdded(address indexed _opco, uint256 indexed _lastCursor);

    /**
     * @notice Emitted when citizens are removed
     *
     * @param _opco OPCO address
     * @param _removed Address of the citizen removed
     */
    event CitizenRemoved(address indexed _opco, address indexed _removed);

    /**
     * @notice Emitted when badge NFT is successfully minted
     *
     * @param _minter Address of the citizen
     * @param _opco Address of the opco
     */
    event Minted(address indexed _minter, address indexed _opco);

    /**
     * @notice Emitted when badge NFT is successfully burned
     *
     * @param _burner Address of the burner
     */
    event Burned(address indexed _burner);

    /**
     * @notice Emitted when Metadata is updated
     *
     * @param _role Role
     * @param _adr Address of the opco/citizen
     */
    event MetadataChanged(string _role, address indexed _adr);

    /**
     * @notice Modifier to only allow addresses with valid OP role to make
     * certain function calls
     */
    modifier onlyOP() {
        require(isOP(msg.sender), "Error: Invalid OP");
        _;
    }

    /**
     * @notice Modifier to only allow addresses with valid OPCO role to make
     * certain function calls
     */
    modifier onlyOPCO() {
        require(isOPCO(msg.sender) && opcos[opcoIndex[msg.sender]].valid, "Error: Invalid OPCO");
        _;
    }

    /**
     * @notice Modifier to only allow addresses with valid Citizen role to make
     * certain function calls
     */
    modifier onlyCitizen() {
        require(
            isCitizen(msg.sender) && citizens[citizenIndex[msg.sender]].valid,
            "Error: Invalid Citizen"
        );
        _;
    }

    /**
     * @param _badgeContract Address of the Badge contract
     * @param _maxOPLimit Maximum ops that can be added in a single transaction
     * @param _maxOPCOLimit Maximum opcos that can be added in a single transaction
     * @param _maxCitizenLimit Maximum citizens that can be added in a single transaction
     * @param _ops Array of addresses that will be given OP role
     */
    constructor(
        address _badgeContract,
        uint256 _maxOPLimit,
        uint256 _maxOPCOLimit,
        uint256 _maxCitizenLimit,
        address[] memory _ops
    ) payable {
        badgeContract = _badgeContract;
        maxOPLimit = _maxOPLimit;
        maxOPCOLimit = _maxOPCOLimit;
        maxCitizenLimit = _maxCitizenLimit;
        require(_ops.length <= maxOPLimit, "OP limit crossed");
        for (uint256 i = 0; i < _ops.length; i++) {
            _newOP(_ops[i]);
        }
    }

    /***********************
     ***** OP CONTROL ******
     ***********************/

    /**
     * @notice Adds given addresses to the OP role
     *
     * @param _adrs Array of addresses which needs to be added to the OP role
     */
    function addOPs(address[] calldata _adrs) external onlyOP {
        require(_adrs.length <= maxOPLimit, "OP limit crossed");
        for (uint256 i = 0; i < _adrs.length; i++) {
            _newOP(_adrs[i]);
        }
        emit OPsAdded(msg.sender);
    }

    /**
     * @notice Adds given addresses to the OPCO role
     *
     * @param _adrs Array of addresses which needs to be added to the OPCO role
     * @param _supplies Array of supplies for the given addresses
     */
    function addOPCOs(address[] calldata _adrs, uint256[] memory _supplies) external onlyOP {
        require(_adrs.length <= maxOPCOLimit, "OPCO limit crossed");
        for (uint256 i = 0; i < _adrs.length; i++) {
            _newOPCO(_adrs[i], _supplies[i]);
        }
        emit OPCOsAdded(msg.sender, opcoCount);
    }

    /**
     * @notice Updates metadata hash of the OP
     *
     * @param _metadata Metadata hash
     */
    function updateOPMetadata(bytes32 _metadata) external onlyOP {
        ops[opIndex[msg.sender]].metadata = _metadata;
        emit MetadataChanged("OP", msg.sender);
    }

    /**
     * @notice Invalidate the given OPCO address i.e setting an opco as inacive
     * or blocking an opco
     *
     * @param _opco OPCO address that needs to be set as invalid
     */
    function invalidateOPCO(address _opco) external onlyOP {
        opcos[opcoIndex[_opco]].valid = false;
    }

    /***********************
     **** OPCO CONTROL *****
     ***********************/

    /**
     * @notice Adds given addresses to the Citizen role
     *
     * @param _adrs Array of addresses which needs to be added to the Citizen role
     */
    function addCitizens(address[] calldata _adrs) external onlyOPCO {
        if (
            opcos[opcoIndex[msg.sender]].citizens.length + _adrs.length >=
            opcos[opcoIndex[msg.sender]].supply
        ) {
            revert ExceedsCitizenSupply(opcos[opcoIndex[msg.sender]].supply);
        }
        require(_adrs.length <= maxCitizenLimit, "Citizen limit crossed");

        for (uint256 i = 0; i < _adrs.length; i++) {
            _newCitizen(_adrs[i]);
        }
        emit CitizensAdded(msg.sender, citizenCount);
    }

    /**
     * @notice Removes given address from the Citizen role
     *
     * @param _adr Address which needs to be removed from the Citizen role
     */
    function removeCitizen(address _adr) external onlyOPCO {
        require(citizens[citizenIndex[_adr]].opco == msg.sender, "Not OPCO of Citizen");
        // Remove citizen address from OPCO data storage
        _deleteOPCOCitizen(msg.sender, _adr);
        // Remove Citizen data storage
        _deleteCitizen(_adr);
        emit CitizenRemoved(msg.sender, _adr);
    }

    /**
     * @notice Updates metadata hash of the OPCO
     *
     * @param _metadata Metadata hash
     */
    function updateOPCOMetadata(bytes32 _metadata) external onlyOPCO {
        opcos[opcoIndex[msg.sender]].metadata = _metadata;
        emit MetadataChanged("OPCO", msg.sender);
    }

    /**
     * @notice Invalidate the given Citizen address i.e setting a citizen as inacive
     * or blocking a citizen
     *
     * @param _citizen Citizen address that needs to be set as invalid
     */
    function invalidateCitizen(address _citizen) external onlyOPCO {
        require(msg.sender == citizens[citizenIndex[_citizen]].opco, "Not OPCO of Citizen");
        citizens[citizenIndex[_citizen]].valid = false;
    }

    /***********************
     *** CITIZEN CONTROL ***
     ***********************/

    /**
     * @notice Mints the soulbound badge NFT.
     */
    function mint() external onlyCitizen {
        require(IBadge(badgeContract).balanceOf(msg.sender) == 0, "Citizen already minted");
        IBadge(badgeContract).mint(msg.sender);
        citizens[citizenIndex[msg.sender]].minted = true;
        opcos[opcoIndex[citizens[citizenIndex[msg.sender]].opco]].minted++;
        emit Minted(msg.sender, citizens[citizenIndex[msg.sender]].opco);
    }

    /**
     * @notice Burns the soulbound badge NFT.
     *
     * @param _id The token ID of the NFT
     */
    function burn(uint256 _id) external onlyCitizen {
        require(IBadge(badgeContract).ownerOf(_id) == msg.sender, "Not badge owner");
        IBadge(badgeContract).burn(_id);
        citizens[citizenIndex[msg.sender]].minted = false;
        opcos[opcoIndex[citizens[citizenIndex[msg.sender]].opco]].minted--;
        emit Burned(msg.sender);
    }

    /**
     * @notice Delegates the badge voting power to a different citizen
     *
     * @param _adr Address to which the badge voting power needs to be delegated
     */
    function delegate(address _adr) external onlyCitizen {
        require(
            isCitizen(_adr) &&
                citizens[citizenIndex[_adr]].valid &&
                citizens[citizenIndex[msg.sender]].delegate == address(0),
            "Invalid delegation"
        );
        require(msg.sender != _adr, "Self-delegation not allowed");
        require(citizens[citizenIndex[msg.sender]].minted, "Citizen has not minted");
        require(citizens[citizenIndex[_adr]].minted, "Delegated has not minted");
        citizens[citizenIndex[msg.sender]].delegate = _adr;
        citizens[citizenIndex[_adr]].power++;
    }

    function vote(bytes calldata _ballot) external onlyCitizen {
        require(
            citizens[citizenIndex[msg.sender]].delegate == address(0),
            "Delegated to another citizen"
        );
        require(citizens[citizenIndex[msg.sender]].minted, "Citizen has not minted");
        citizens[citizenIndex[msg.sender]].ballot = _ballot;
    }

    /**
     * @notice Undelegates the badge voting power
     *
     * @param _adr Address of the citizen from which voting power needs to be undelegated
     */
    function undelegate(address _adr) external onlyCitizen {
        require(citizens[citizenIndex[msg.sender]].delegate == _adr, "Invalid undelegate request");
        citizens[citizenIndex[msg.sender]].delegate = address(0);
        citizens[citizenIndex[_adr]].power--;
    }

    /**
     * @notice Updates metadata hash of the Citizen
     *
     * @param _metadata Metadata hash
     */
    function updateCitizenMetadata(bytes32 _metadata) external onlyCitizen {
        citizens[citizenIndex[msg.sender]].metadata = _metadata;
        emit MetadataChanged("Citizen", msg.sender);
    }

    /***********************
     ******** MISC. ********
     ***********************/

    /**
     * @notice Returns whether the given address has the OP role or not
     *
     * @param _adr Address for which the role data is needed
     */
    function isOP(address _adr) public view returns (bool) {
        return ops[opIndex[_adr]].op == _adr;
    }

    /**
     * @notice Returns whether the given address has the OPCO role or not
     *
     * @param _adr Address for which the role data is needed
     */
    function isOPCO(address _adr) public view returns (bool) {
        return opcos[opcoIndex[_adr]].co == _adr;
    }

    /**
     * @notice Returns whether the given address has the Citizen role or not
     *
     * @param _adr Address for which the role data is needed
     */
    function isCitizen(address _adr) public view returns (bool) {
        return citizens[citizenIndex[_adr]].citizen == _adr;
    }

    /**
     * @notice Returns the array of all the ops
     */
    function getOPs() external view returns (OP[] memory) {
        return ops;
    }

    /**
     * @notice Returns the OP struct data for the given OP address
     *
     * @param _adr Address for which the data is needed
     */
    function getOP(address _adr) external view returns (OP memory) {
        return ops[opIndex[_adr]];
    }

    /**
     * @notice Returns the array of opcos starting from the given
     * cursor i.e index of the opcos array
     *
     * @param cursor Index of the opcos array
     * @param count The number of OPCO structs to be returned starting from the cursor index
     */
    function getOPCOs(uint256 cursor, uint256 count)
        public
        view
        returns (OPCO[] memory, uint256 newCursor)
    {
        uint256 length = count;
        if (length > opcos.length - cursor) {
            length = opcos.length - cursor;
        }
        OPCO[] memory values = new OPCO[](length);
        for (uint256 i = 0; i < length; i++) {
            values[i] = opcos[cursor + i];
        }
        return (values, count + length);
    }

    /**
     * @notice Returns the OPCO struct data for the given OPCO address
     *
     * @param _adr Address for which the data is needed
     */
    function getOPCO(address _adr) public view returns (OPCO memory) {
        return opcos[opcoIndex[_adr]];
    }

    /**
     * @notice Returns the array of citizens starting from the given
     * cursor i.e index of the citizens array
     *
     * @param cursor Index of the citizens array
     * @param count The number of Citizen structs to be returned starting from the cursor index
     */
    function getCitizens(uint256 cursor, uint256 count)
        public
        view
        returns (Citizen[] memory, uint256 newCursor)
    {
        uint256 length = count;
        if (length > citizens.length - cursor) {
            length = citizens.length - cursor;
        }
        Citizen[] memory values = new Citizen[](length);
        for (uint256 i = 0; i < length; i++) {
            values[i] = citizens[cursor + i];
        }
        return (values, count + length);
    }

    /**
     * @notice Returns the Citizen struct data for the given Citizen address
     *
     * @param _adr Address for which the data is needed
     */
    function getCitizen(address _adr) public view returns (Citizen memory) {
        return citizens[citizenIndex[_adr]];
    }

    /**
     * @notice Internal function to add an address to the OP role
     *
     * @param _adr Address that needs to be added to the OP role
     */
    function _newOP(address _adr) private {
        if (ops.length > 0) require(!isOP(_adr), "Address already OP");
        OP memory op = OP({ op: _adr, metadata: "" });
        ops.push(op);
        opIndex[_adr] = ops.length - 1;
    }

    /**
     * @notice Internal function to add an address to the OPCO role
     *
     * @param _adr Address that needs to be added to the OPCO role
     * @param _supply Citizen supply of the given OPCO address
     */
    function _newOPCO(address _adr, uint256 _supply) private {
        if (opcos.length > 0 && isOPCO(_adr)) {
            revert AlreadyOPCO(_adr);
        }
        address[] memory _citizens;
        OPCO memory opco = OPCO({
            co: _adr,
            valid: true,
            citizens: _citizens,
            supply: _supply,
            minted: 0,
            metadata: bytes32(0)
        });
        opcos.push(opco);
        opcoIndex[_adr] = opcos.length - 1;
        opcoCount++;
    }

    /**
     * @notice Internal function to add an address to the Citizen role
     *
     * @param _adr Address that needs to be added to the Citizen role
     */
    function _newCitizen(address _adr) private {
        if (citizens.length > 0 && isCitizen(_adr)) {
            revert AlreadyCitizen(_adr);
        }
        Citizen memory citizen = Citizen({
            citizen: _adr,
            valid: true,
            opco: msg.sender,
            minted: false,
            ballot: bytes(""),
            delegate: address(0),
            power: 1,
            metadata: bytes32(0)
        });
        citizens.push(citizen);
        citizenIndex[_adr] = citizens.length - 1;
        opcos[opcoIndex[msg.sender]].citizens.push(_adr);
        citizenCount++;
    }

    /**
     * @notice Internal function to delete an address from the Citizen role
     *
     * @param _adr Address that needs to be deleted from the Citizen role
     */
    function _deleteCitizen(address _adr) private {
        // ADDME: check if the index map is maxint (i.e. already deleted)
        uint256 _delIndex = citizenIndex[_adr];
        // move all elements to the left, starting from the deletion index + 1
        for (uint256 i = _delIndex; i < citizens.length - 1; i++) {
            citizens[i] = citizens[i + 1];
        }
        citizens.pop(); // delete the last item
        // set the index map to the max int value
        citizenIndex[_adr] = type(uint256).max;
        citizenCount--;
    }

    /**
     * @notice Internal function to delete an address from the respective OPCO struct
     *
     * @param _opco Address of the opco that the citizen belongs to
     * @param _adr Address the citizen that needs to be deleted
     */
    function _deleteOPCOCitizen(address _opco, address _adr) private {
        uint256 _opcoIndex = opcoIndex[_opco];
        uint256 _delIndex;
        for (uint256 i = 0; i < opcos[_opcoIndex].citizens.length; i++) {
            if (opcos[_opcoIndex].citizens[i] == _adr) {
                _delIndex = i;
                break;
            }
            // TODO: add revert
        }
        // move all elements to the left, starting from the deletion index + 1
        for (uint256 i = _delIndex; i < opcos[_opcoIndex].citizens.length - 1; i++) {
            opcos[opcoIndex[_opco]].citizens[i] = opcos[_opcoIndex].citizens[i + 1];
        }
        opcos[opcoIndex[_opco]].citizens.pop();
    }

    /**
     * @notice Updates the address of the Badge contract
     *
     * @param _badgeContract Address of the new Badge contract
     */
    function updateBadgeContract(address _badgeContract) external onlyOwner {
        badgeContract = _badgeContract;
    }
}
