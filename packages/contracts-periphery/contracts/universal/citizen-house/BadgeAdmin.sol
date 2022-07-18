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
     * @notice Emitted when OPs are added
     *
     * @param _sender Address of the sender
     */
    event OPsAdded(address indexed _sender);

    /**
     * @notice Emitted when OPCOs are added
     *
     * @param _op OP address
     * @param _lastCursor Last index of the OPCO array
     */
    event OPCOsAdded(address indexed _op, uint256 indexed _lastCursor);

    /**
     * @notice Emitted when Citizens are added
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
     * @notice Emitted when successfully minted
     *
     * @param _minter Address of the citizen
     * @param _opco Address of the opco
     */
    event Minted(address indexed _minter, address indexed _opco);

    /**
     * @notice Emitted when successfully burned
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

    modifier onlyOP() {
        require(isOP(msg.sender), "Error: Invalid OP");
        _;
    }

    modifier onlyOPCO() {
        require(isOPCO(msg.sender) && OPCOs[OPCOIndexMap[msg.sender]].valid, "Error: Invalid OPCO");
        _;
    }

    modifier onlyCitizen() {
        require(
            isCitizen(msg.sender) && Citizens[CitizenIndexMap[msg.sender]].valid,
            "Error: Invalid Citizen"
        );
        _;
    }

    struct OP {
        address op;
        bytes32 metadata;
    }

    struct OPCO {
        address co;
        bool valid;
        address[] citizens;
        uint256 supply;
        uint256 minted;
        bytes32 metadata;
    }

    struct Citizen {
        address citizen;
        bool valid;
        bool minted;
        address opco;
        address representative;
        uint256 delegations;
        bytes32 metadata;
    }

    uint256 public CitizenCount;
    uint256 public OPCOCount;

    uint256 public maxOPLimit;
    uint256 public maxOPCOLimit;
    uint256 public maxCitizenLimit;

    OP[] internal OPs;
    OPCO[] internal OPCOs;
    Citizen[] internal Citizens;

    address public BadgeContract;

    mapping(address => uint256) internal OPIndexMap;
    mapping(address => uint256) internal OPCOIndexMap;
    mapping(address => uint256) internal CitizenIndexMap;

    /*///////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

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

    /*///////////////////////////////////////////////////////////////
                              OP  LOGIC
    //////////////////////////////////////////////////////////////*/

    function addOPs(address[] calldata _adrs) external onlyOP {
        require(_adrs.length <= maxOPLimit, "OP limit crossed");
        for (uint256 i = 0; i < _adrs.length; i++) {
            _newOP(_adrs[i]);
        }
        emit OPsAdded(msg.sender);
    }

    function addOPCOs(address[] calldata _adrs, uint256[] memory _supplies) external onlyOP {
        require(_adrs.length <= maxOPCOLimit, "OPCO limit crossed");
        for (uint256 i = 0; i < _adrs.length; i++) {
            _newOPCO(_adrs[i], _supplies[i]);
        }
        emit OPCOsAdded(msg.sender, OPCOCount);
    }

    function updateOPMetadata(bytes32 _metadata) external onlyOP {
        OPs[OPIndexMap[msg.sender]].metadata = _metadata;
        emit MetadataChanged("OP", msg.sender);
    }

    function invalidateOPCO(address _opco) external onlyOP {
        OPCOs[OPCOIndexMap[_opco]].valid = false;
    }

    // TODO: Remove OPCO & OP Methods

    /*///////////////////////////////////////////////////////////////
                              OPCO  LOGIC
    //////////////////////////////////////////////////////////////*/

    function addCitizens(address[] calldata _adrs) external onlyOPCO {
        if (
            OPCOs[OPCOIndexMap[msg.sender]].citizens.length + _adrs.length >=
            OPCOs[OPCOIndexMap[msg.sender]].supply
        ) {
            revert ExceedsCitizenSupply(OPCOs[OPCOIndexMap[msg.sender]].supply);
        }
        require(_adrs.length <= maxCitizenLimit, "Citizen limit crossed");

        for (uint256 i = 0; i < _adrs.length; i++) {
            _newCitizen(_adrs[i]);
        }
        emit CitizensAdded(msg.sender, CitizenCount);
    }

    function removeCitizen(address _adr) external onlyOPCO {
        require(Citizens[CitizenIndexMap[_adr]].opco == msg.sender, "Error: Not OPCO of Citizen");
        // Remove citizen address from OPCO data storage
        _deleteOPCOCitizen(msg.sender, _adr);
        // Remove Citizen data storage
        _deleteCitizen(_adr);
        emit CitizenRemoved(msg.sender, _adr);
    }

    function updateOPCOMetadata(bytes32 _metadata) external onlyOPCO {
        OPCOs[OPCOIndexMap[msg.sender]].metadata = _metadata;
        emit MetadataChanged("OPCO", msg.sender);
    }

    function invalidateCitizen(address _citizen) external onlyOPCO {
        require(
            Citizens[CitizenIndexMap[_citizen]].opco == msg.sender,
            "Error: Not OPCO of Citizen"
        );
        Citizens[CitizenIndexMap[_citizen]].valid = false;
    }

    /*///////////////////////////////////////////////////////////////
                            CITIZEN LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @notice Mint
    /// @dev Mints the soulbound ERC721 token.
    function mint() external onlyCitizen {
        require(IBadge(BadgeContract).balanceOf(msg.sender) == 0, "Citizenship already minted");
        IBadge(BadgeContract).mint(msg.sender);
        Citizens[CitizenIndexMap[msg.sender]].minted = true;
        OPCOs[OPCOIndexMap[Citizens[CitizenIndexMap[msg.sender]].opco]].minted++;
        emit Minted(msg.sender, Citizens[CitizenIndexMap[msg.sender]].opco);
    }

    /// @notice ToDo: Handling Burn
    function burn(uint256 _id) external {
        require(IBadge(BadgeContract).ownerOf(_id) == msg.sender, "Error: Not badge owner");
        IBadge(BadgeContract).burn(_id);
        Citizens[CitizenIndexMap[msg.sender]].minted = false;
        OPCOs[OPCOIndexMap[Citizens[CitizenIndexMap[msg.sender]].opco]].minted--;
        emit Burned(msg.sender);
    }

    function delegate(address _adr) external onlyCitizen {
        // ADDME: Check if _adr is a citizen
        Citizens[CitizenIndexMap[msg.sender]].representative = _adr;
        Citizens[CitizenIndexMap[_adr]].delegations++;
    }

    function undelegate(address _adr) external onlyCitizen {
        Citizens[CitizenIndexMap[msg.sender]].representative = address(0);
        Citizens[CitizenIndexMap[_adr]].delegations--;
    }

    function updateCitizenMetadata(bytes32 _metadata) external onlyCitizen {
        Citizens[CitizenIndexMap[msg.sender]].metadata = _metadata;
        emit MetadataChanged("Citizen", msg.sender);
    }

    /*///////////////////////////////////////////////////////////////
                            HELPER LOGIC
  //////////////////////////////////////////////////////////////*/

    function isOP(address _adr) public view returns (bool) {
        return OPs[OPIndexMap[_adr]].op == _adr;
    }

    function isOPCO(address _adr) public view returns (bool) {
        return OPCOs[OPCOIndexMap[_adr]].co == _adr;
    }

    function isCitizen(address _adr) public view returns (bool) {
        return Citizens[CitizenIndexMap[_adr]].citizen == _adr;
    }

    function getOPs() external view returns (OP[] memory) {
        return OPs;
    }

    function getOP(address _adr) external view returns (OP memory) {
        return OPs[OPIndexMap[_adr]];
    }

    function getOPCOs(uint256 cursor, uint256 count)
        public
        view
        returns (OPCO[] memory, uint256 newCursor)
    {
        uint256 length = count;
        if (length > OPCOs.length - cursor) {
            length = OPCOs.length - cursor;
        }
        OPCO[] memory values = new OPCO[](length);
        for (uint256 i = 0; i < length; i++) {
            values[i] = OPCOs[cursor + i];
        }
        return (values, count + length);
    }

    function getOPCO(address _adr) public view returns (OPCO memory) {
        return OPCOs[OPCOIndexMap[_adr]];
    }

    function getCitizens(uint256 cursor, uint256 count)
        public
        view
        returns (Citizen[] memory, uint256 newCursor)
    {
        uint256 length = count;
        if (length > Citizens.length - cursor) {
            length = Citizens.length - cursor;
        }
        Citizen[] memory values = new Citizen[](length);
        for (uint256 i = 0; i < length; i++) {
            values[i] = Citizens[cursor + i];
        }
        return (values, count + length);
    }

    function getCitizen(address _adr) public view returns (Citizen memory) {
        return Citizens[CitizenIndexMap[_adr]];
    }

    /*///////////////////////////////////////////////////////////////
                            CONTRACT LOGIC
    //////////////////////////////////////////////////////////////*/

    function _newOP(address _adr) private {
        if (OPs.length > 0) require(!isOP(_adr), "The address already has an OP role");
        OP memory op = OP({ op: _adr, metadata: "" });
        OPs.push(op);
        OPIndexMap[_adr] = OPs.length - 1;
    }

    function _newOPCO(address _adr, uint256 _supply) private {
        if (OPCOs.length > 0 && isOPCO(_adr)) {
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
        OPCOs.push(opco);
        OPCOIndexMap[_adr] = OPCOs.length - 1;
        OPCOCount++;
    }

    function _newCitizen(address _adr) private {
        if (Citizens.length > 0 && isCitizen(_adr)) {
            revert AlreadyCitizen(_adr);
        }
        Citizen memory citizen = Citizen({
            citizen: _adr,
            valid: true,
            opco: msg.sender,
            minted: false,
            representative: address(0),
            delegations: 1,
            metadata: bytes32(0)
        });
        Citizens.push(citizen);
        CitizenIndexMap[_adr] = Citizens.length - 1;
        OPCOs[OPCOIndexMap[msg.sender]].citizens.push(_adr);
        CitizenCount++;
    }

    function _deleteCitizen(address _adr) private {
        // ADDME: check if the index map is maxint (i.e. already deleted)
        uint256 _delIndex = CitizenIndexMap[_adr];
        // move all elements to the left, starting from the deletion index + 1
        for (uint256 i = _delIndex; i < Citizens.length - 1; i++) {
            Citizens[i] = Citizens[i + 1];
        }
        Citizens.pop(); // delete the last item
        // set the index map to the max int value
        CitizenIndexMap[_adr] = type(uint256).max;
        CitizenCount--;
    }

    function _deleteOPCOCitizen(address _opco, address _adr) private {
        uint256 _opcoIndex = OPCOIndexMap[_opco];
        uint256 _delIndex;
        for (uint256 i = 0; i < OPCOs[_opcoIndex].citizens.length; i++) {
            if (OPCOs[_opcoIndex].citizens[i] == _adr) {
                _delIndex = i;
                break;
            }
            // TODO: add revert
        }
        // move all elements to the left, starting from the deletion index + 1
        for (uint256 i = _delIndex; i < OPCOs[_opcoIndex].citizens.length - 1; i++) {
            OPCOs[OPCOIndexMap[_opco]].citizens[i] = OPCOs[_opcoIndex].citizens[i + 1];
        }
        OPCOs[OPCOIndexMap[_opco]].citizens.pop();
    }

    // TODO: delete opco, which deletes the citizen data too, onlyOP
    // function _deleteOPCO(address _adr) internal onlyOP {}

    // TODO: delete OP
    // function _deleteOP(address _adr) internal onlyOP {}

    /// @notice AdminContract
    /// @dev Update Admin Contract
    function updateBadgeContract(address _badgeContract) external onlyOwner {
        BadgeContract = _badgeContract;
    }
}
