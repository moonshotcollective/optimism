// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { IBadge } from "./IBadge.sol";

/**
 * @title  Badge Administrator
 * @notice The Badge Administrator is intended to handle the adminstration of Citizen House and its
 *         periphery contracts. The control is heirarchial and consists of three seperate roles:
 *         OP, OP Company, and Citizen. The OP role grants top level access, with the ability to
 *         add/block OP Companies, as well as other OPs. The OP Company role grants secondary
 *         access with the ability to add/block/remove OP Company Citizens. The Citizen role grants
 *         access to the Citizen House and its periphery contracts, namely the ability to mint a
 *         Soulbound ERC-721 token which is used to participate by vote in a Citizen House grant
 *         round.
 * @author OPTIMISM + GITCOIN
 */
contract BadgeAdmin is Ownable {
    /**
     * @notice Represents an OP.
     */
    struct OP {
        address op;
        bytes32 metadata;
    }

    /**
     * @notice Represents an OP Company.
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
     * @notice Represents a Citizen.
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
     * @notice Total count of all stored Citizens
     */
    /// REMOVE
    uint256 public citizenCount;

    /**
     * @notice Total count of opcos added
     */
    /// REMOVE
    uint256 public opcoCount;

    /**
     * @notice Maximum number of OP roles that can assigned in a single tx.
     */
    uint256 public maxOPLimit;

    /**
     * @notice Maximum number of OP company roles that can be assigned in a single tx.
     */
    uint256 public maxOPCOLimit;

    /**
     * @notice Maximum number of Citizen roles that can be assigned in a single tx.
     */
    uint256 public maxCitizenLimit;

    /**
     * @notice OP storage.
     */
    OP[] internal ops;

    /**
     * @notice OP Company storage.
     */
    OPCO[] internal opcos;

    /**
     * @notice Citizen storage.
     */
    Citizen[] internal citizens;

    /**
     * @notice Citizen Badge Contract address.
     */
    address public BadgeContract;

    /**
     * @notice Maps from address to the OP role index.
     */
    mapping(address => uint256) internal opIndex;

    /**
     * @notice Maps from address to the OP Company role index.
     */
    mapping(address => uint256) internal opcoIndex;

    /**
     * @notice Maps from address to the Citizen role index.
     */
    mapping(address => uint256) internal citizenIndex;

    /**
     * @notice Emitted when OP role(s) are assigned.
     *
     * @param _op Address of the OP caller.
     */
    event OPsAdded(address indexed _op);

    /**
     * @notice Emitted when OP Company role(s) are assigned.
     *
     * @param _op Address of the OP caller.
     * @param _lastCursor Last cursor of the OP Company roles.
     */
    event OPCOsAdded(address indexed _op, uint256 indexed _lastCursor);

    /**
     * @notice Emitted when Citizen role(s) are assigned.
     *
     * @param _opco Address of the OPCO caller.
     * @param _lastCursor Last cursor of the Citizen roles.
     */
    event CitizensAdded(address indexed _opco, uint256 indexed _lastCursor);

    /**
     * @notice Emitted when a Citizen is removed.
     *
     * @param _opco Address of the OPCO caller.
     * @param _removed Address of the removed Citizen.
     */
    event CitizenRemoved(address indexed _opco, address indexed _removed);

    /**
     * @notice Emitted when the Citizen Badge is minted.
     *
     * @param _minter Address of the Citizen caller.
     * @param _opco Address of the Citizen's OPCO.
     */
    event Minted(address indexed _minter, address indexed _opco);

    /**
     * @notice Emitted when Citizen Badge is burned.
     *
     * @param _burner Address of the Citizen caller.
     */
    event Burned(address indexed _burner);

    /**
     * @notice Emitted when a role's metadata is updated.
     *
     * @param _role Role of caller that updated its metadata.
     * @param _adr Address of the caller that updated its metadata.
     */
    event MetadataChanged(string _role, address indexed _adr);

    /**
     * @notice Modifier that prevents callers other than an OP from calling the function.
     */
    modifier onlyOP() {
        require(isOP(msg.sender), "Error: Invalid OP");
        _;
    }

    /**
     * @notice Modifier that prevents callers other than an OP Company from calling the function.
     *         Note: The OP Company caller must not be invalidated.
     */
    modifier onlyOPCO() {
        require(isOPCO(msg.sender) && opcos[opcoIndex[msg.sender]].valid, "Error: Invalid OPCO");
        _;
    }

    /**
     * @notice Modifier that prevents callers other than a Citizen from calling the function.
     *         Note: The Citizen caller must not be invalidated.
     */
    modifier onlyCitizen() {
        require(
            isCitizen(msg.sender) && citizens[citizenIndex[msg.sender]].valid,
            "Error: Invalid Citizen"
        );
        _;
    }

    /**
     * @param _badgeContract Address of the Citizen Badge contract.
     * @param _maxOPLimit Maximum number of OP roles that can be assigned in a single tx.
     * @param _maxOPCOLimit Maximum number of OP Company roles that can be assigned in a single tx.
     * @param _maxCitizenLimit Maximum number Citizens roles that can be assigned in a single tx.
     * @param _ops Array of addresses that will be assigned OP roles on deployment.
     */
    constructor(
        address _badgeContract,
        uint256 _maxOPLimit,
        uint256 _maxOPCOLimit,
        uint256 _maxCitizenLimit,
        address[] memory _ops
    ) payable {
        BadgeContract = _badgeContract;
        maxOPLimit = _maxOPLimit;
        maxOPCOLimit = _maxOPCOLimit;
        maxCitizenLimit = _maxCitizenLimit;
        require(_ops.length <= maxOPLimit, "OP limit crossed");
        for (uint256 i = 0; i < _ops.length; i++) {
            _newOP(_ops[i]);
        }
    }

    /***********************
     ***** OP  CONTROL *****
     ***********************/

    /**
     * @notice Assign OP roles.
     *
     * @param _adrs Array of addresses to be assigned an OP role.
     */
    function addOPs(address[] calldata _adrs) external onlyOP {
        require(_adrs.length <= maxOPLimit, "OP limit crossed");
        for (uint256 i = 0; i < _adrs.length; i++) {
            _newOP(_adrs[i]);
        }
        emit OPsAdded(msg.sender);
    }

    /**
     * @notice Assign OP Company roles.
     *
     * @param _adrs Array of addresses to be assigned an OP Company role.
     * @param _supplies Array of the mintable citizen supply for each corresponding OP Company.
     */
    function addOPCOs(address[] calldata _adrs, uint256[] memory _supplies) external onlyOP {
        require(_adrs.length <= maxOPCOLimit, "OPCO limit crossed");
        for (uint256 i = 0; i < _adrs.length; i++) {
            _newOPCO(_adrs[i], _supplies[i]);
        }
        emit OPCOsAdded(msg.sender, opcoCount);
    }

    /**
     * @notice Update OP metadata.
     *
     * @param _metadata A 32-byte hash of metadata.
     */
    function updateOPMetadata(bytes32 _metadata) external onlyOP {
        ops[opIndex[msg.sender]].metadata = _metadata;
        emit MetadataChanged("OP", msg.sender);
    }

    /**
     * @notice Invalidate an OP Company.
     *         Note: This is only callable by an OP and doing so will not only block all future
     *         impure function calls by the OP Company, but also recursively invalidate all of
     *         the OP Company's corresponding Citizens.
     *
     * @param _opco Address of the OP Company to invalidate.
     */
    function invalidateOPCO(address _opco) external onlyOP {
        opcos[opcoIndex[_opco]].valid = false;
        // Invalidate all of the OP Compnay citizens, too.
        for (uint256 i = 0; i < opcos[opcoIndex[_opco]].citizens.length; i++) {
            citizens[citizenIndex[opcos[opcoIndex[_opco]].citizens[i]]].valid = false;
        }
    }

    /***********************
     **** OPCO  CONTROL ****
     ***********************/

    /**
     * @notice Assign Citizen roles.
     *         Note: Calling this stores the a new citizen who has the ability to mint a Citizen
     *         Badge. Duplicate ciitzens, either in the same, or different, OP Companies is not
     *         permitted.
     *
     * @param _adrs Array of addresses to be assigned a Citizen role.
     */
    function addCitizens(address[] calldata _adrs) external onlyOPCO {
        require(_adrs.length <= maxCitizenLimit, "Max Citizen limit exceeded");
        require(
            opcos[opcoIndex[msg.sender]].citizens.length + _adrs.length <=
                opcos[opcoIndex[msg.sender]].supply,
            "Citizen supply exceeded"
        );

        for (uint256 i = 0; i < _adrs.length; i++) {
            _newCitizen(_adrs[i]);
        }
        emit CitizensAdded(msg.sender, citizenCount);
    }

    /**
     * @notice Remove a Citizen.
     *         Note: This is only callable by the Citizen's corresponding OP Company, and doing so
     *         will replenish the mintable supply of the OP Company by completely removing the
     *         Citizen from the contract storage.
     *
     * @param _adr Address of Citizen to remove.
     */
    function removeCitizen(address _adr) external onlyOPCO {
        require(citizens[citizenIndex[_adr]].opco == msg.sender, "Not OPCO of Citizen");
        // Remove the citizen from the OPCO citizen-address storage
        _deleteOPCOCitizen(msg.sender, _adr);
        // Remove the citizen from the Citizen storage
        _deleteCitizen(_adr);
        emit CitizenRemoved(msg.sender, _adr);
    }

    /**
     * @notice Update OP Company metadata.
     *
     * @param _metadata 32-byte hash of metadata.
     */
    function updateOPCOMetadata(bytes32 _metadata) external onlyOPCO {
        opcos[opcoIndex[msg.sender]].metadata = _metadata;
        emit MetadataChanged("OPCO", msg.sender);
    }

    /**
     * @notice Invalidate a Citizen.
     *         Note: This is only callable by the Citizen's corresponding OP Company, and doing so
     *         will block all future impure function calls by the Citizen. This will not replenish
     *         the mintable supply of the OP Company.
     *
     * @param _citizen Address of the Citizen to invalidate.
     */
    function invalidateCitizen(address _citizen) external onlyOPCO {
        require(msg.sender == citizens[citizenIndex[_citizen]].opco, "Not OPCO of Citizen");
        citizens[citizenIndex[_citizen]].valid = false;
    }

    /***********************
     *** CITIZEN CONTROL ***
     ***********************/

    /**
     * @notice Mint a Citizen Badge.
     *         Note: This is a ~Soulbound~ ERC721 token which is therefore non-transferable and can
     *         only be burned by the owner of the token. Only a single token can be minted per
     *         assigned Citizen.
     */
    function mint() external onlyCitizen {
        require(IBadge(BadgeContract).balanceOf(msg.sender) == 0, "Citizen already minted");
        IBadge(BadgeContract).mint(msg.sender);
        citizens[citizenIndex[msg.sender]].minted = true;
        opcos[opcoIndex[citizens[citizenIndex[msg.sender]].opco]].minted++;
        emit Minted(msg.sender, citizens[citizenIndex[msg.sender]].opco);
    }

    /**
     * @notice Burn the Citizen Badge.
     *         Note: This is only callable by the owner of the token, and doing so will
     *         replenish the mintable supply of the corresponding OP Company.
     *
     * @param _id The token ID of the Citizen Badge to burn.
     */
    function burn(uint256 _id) external onlyCitizen {
        require(IBadge(BadgeContract).ownerOf(_id) == msg.sender, "Not badge owner");
        IBadge(BadgeContract).burn(_id);
        citizens[citizenIndex[msg.sender]].minted = false;
        opcos[opcoIndex[citizens[citizenIndex[msg.sender]].opco]].minted--;
        emit Burned(msg.sender);
    }

    /**
     * @notice Delegate a Citizen Badge to another Citizen.
     *         Note: This is only callable by the owner of the token, and doing so will increment
     *         the power of the delegatee. The power of the delegator will be decremented which
     *         absolves the ability to participate by vote. The delegatee must own a valid
     *         Citizen Badge.
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
        require(citizens[citizenIndex[_adr]].ballot.length == 0, "Delegatee already voted");
        require(msg.sender != _adr, "Self-delegation not allowed");
        require(citizens[citizenIndex[msg.sender]].minted, "Citizen has not minted");
        require(citizens[citizenIndex[_adr]].minted, "Delegatee has not minted");
        citizens[citizenIndex[msg.sender]].delegate = _adr;
        citizens[citizenIndex[_adr]].power++;
    }

    /**
     * @notice Submit a Vote.
     *         Note: This is only callable by a valid owner of the Citizen Badge token who has not
     *         delegated to another Citizen.
     *
     * @param _ballot Ballot data.
     */
    function vote(bytes calldata _ballot) external onlyCitizen {
        require(
            citizens[citizenIndex[msg.sender]].delegate == address(0),
            "Delegated to another citizen"
        );
        require(citizens[citizenIndex[msg.sender]].minted, "Citizen has not minted");
        citizens[citizenIndex[msg.sender]].ballot = _ballot;
    }

    /**
     * @notice Undelegate a Citizen Badge.
     *         Note: This is only callable by a valid owner of the Citizen Badge token who has
     *         delegated to another Citizen. Doing so will decrement the power of the delegatee and
     *         resolve the Citizen's ability to participate by vote.
     *
     * @param _adr Address of the citizen from which voting power needs to be undelegated
     */
    function undelegate(address _adr) external onlyCitizen {
        require(
            citizens[citizenIndex[_adr]].ballot.length == 0,
            "Delegatee has submitted a ballot"
        );
        require(citizens[citizenIndex[msg.sender]].delegate == _adr, "Invalid undelegate request");
        citizens[citizenIndex[msg.sender]].delegate = address(0);
        citizens[citizenIndex[_adr]].power--;
    }

    /**
     * @notice Updates metadata hash of the Citizen
     *
     * @param _metadata 32-byte metadata hash
     */
    function updateCitizenMetadata(bytes32 _metadata) external onlyCitizen {
        citizens[citizenIndex[msg.sender]].metadata = _metadata;
        emit MetadataChanged("Citizen", msg.sender);
    }

    /***********************
     ******** MISC. ********
     ***********************/

    /**
     * @notice Check if a given address is an OP.
     *
     * @param _adr Address to check.
     */
    function isOP(address _adr) public view returns (bool) {
        return ops[opIndex[_adr]].op == _adr;
    }

    /**
     * @notice Check if a given address is an OPCO.
     *
     * @param _adr Address to check.
     */
    function isOPCO(address _adr) public view returns (bool) {
        if (opcos.length == 0) return false;
        return opcos[opcoIndex[_adr]].co == _adr;
    }

    /**
     * @notice Check if a given address is a Citizen.
     *
     * @param _adr Address to check.
     */
    function isCitizen(address _adr) public view returns (bool) {
        if (citizens.length == 0) return false;
        return citizens[citizenIndex[_adr]].citizen == _adr;
    }

    /**
     * @notice Get an array of all the OPs.
     */
    function getOPs() external view returns (OP[] memory) {
        return ops;
    }

    /**
     * @notice Get an OP by address.
     *
     * @param _adr Address to obtain data for.
     */
    function getOP(address _adr) external view returns (OP memory) {
        return ops[opIndex[_adr]];
    }

    /**
     * @notice Get the paginated list of OPs.
     *
     * @param cursor The list cursor.
     * @param count The count of items to return after the cursor.
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
     * @notice Get an OPCO by address.
     *
     * @param _adr Address to obtain data for.
     */
    function getOPCO(address _adr) public view returns (OPCO memory) {
        return opcos[opcoIndex[_adr]];
    }

    /**
     * @notice Get the paginated list of Citizens.
     *
     * @param cursor The list cursor.
     * @param count The count of items to return after the cursor.
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
     * @notice Get a Citizen by address.
     *
     * @param _adr Address to obtain data for.
     */
    function getCitizen(address _adr) public view returns (Citizen memory) {
        return citizens[citizenIndex[_adr]];
    }

    /**
     * @notice (Internal) Initialize a new OP.
     *
     * @param _adr Address of the OP.
     */
    function _newOP(address _adr) private {
        if (ops.length > 0) require(!isOP(_adr), "Address already OP");
        OP memory op = OP({ op: _adr, metadata: "" });
        ops.push(op);
        opIndex[_adr] = ops.length - 1;
    }

    /**
     * @notice (Internal) Initialize a new OPCO.
     *
     * @param _adr Address of the OPCO.
     * @param _supply The mintable citizen badge supply of the OPCO.
     */
    function _newOPCO(address _adr, uint256 _supply) private {
        require(!isCitizen(_adr), "Address already Citizen");
        require(!isOPCO(_adr), "Address already OPCO");
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
     * @notice (Internal) Initialize a new Citizen.
     *
     * @param _adr Address of the Citizen.
     */
    function _newCitizen(address _adr) private {
        require(!isCitizen(_adr), "Address already Citizen");
        require(!isOPCO(_adr), "Address already OPCO");
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
     * @notice (Internal) Delate a Citizen.
     *         Note: This completely removes the citizen from the Citizen contract storage.
     *
     * @param _adr Address of the citizen to delete.
     */
    function _deleteCitizen(address _adr) private {
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
     * @notice (Internal) Delate an OPCO Citizen.
     *         Note: This completely removes the citizen from the OPCO citizens contract storage.
     *
     * @param _opco Address of the OPCO that contains the citizen to be deleted.
     * @param _adr Address the of the citizen to delete.
     */
    function _deleteOPCOCitizen(address _opco, address _adr) private {
        uint256 _opcoIndex = opcoIndex[_opco];
        uint256 _delIndex;
        for (uint256 i = 0; i < opcos[_opcoIndex].citizens.length; i++) {
            if (opcos[_opcoIndex].citizens[i] == _adr) {
                _delIndex = i;
                break;
            }
        }
        // move all elements to the left, starting from the deletion index + 1
        for (uint256 i = _delIndex; i < opcos[_opcoIndex].citizens.length - 1; i++) {
            opcos[opcoIndex[_opco]].citizens[i] = opcos[_opcoIndex].citizens[i + 1];
        }
        opcos[opcoIndex[_opco]].citizens.pop();
    }

    /**
     * @notice Update the Citizen Badge Contract address.
     *
     * @param _badgeContract Address of the Badge Contract
     */
    function updateBadgeContract(address _badgeContract) external onlyOwner {
        BadgeContract = _badgeContract;
    }
}
