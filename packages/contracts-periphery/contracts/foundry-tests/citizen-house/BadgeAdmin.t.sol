// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import { BadgeAdmin } from "../../universal/citizen-house/BadgeAdmin.sol";
import { Badge } from "../../universal/citizen-house/Badge.sol";
import { Test, stdError } from "forge-std/Test.sol";

function mkadr(string memory name) pure returns (address) {
    address adr = address(uint160(uint256(keccak256(abi.encodePacked(name)))));
    return adr;
}

contract TBadge is Badge {
    constructor() Badge("example", "ex", "example.com") {}
}

contract TBadgeAdmin is BadgeAdmin {
    TBadge internal badge;

    address[] opAdrs = [mkadr("op")];
    address[] adrs = [0xa8B3478A436e8B909B5E9636090F2B15f9B311e7];

    function setUp() public {
        badge = new TBadge();
    }

    constructor() BadgeAdmin(address(badge), 100, 100, 100, opAdrs) {}
}

contract BadgeAdminTest is Test {
    TBadgeAdmin internal badgeAdmin;
    TBadge internal badge;

    address opAdr = mkadr("op"); //[0xa8B3478A436e8B909B5E9636090F2B15f9B311e7];
    bytes32 testIPFSHash = 0x0170171c23281b16a3c58934162488ad6d039df686eca806f21eba0cebd03486;

    function setUp() public {
        badgeAdmin = new TBadgeAdmin();
        badge = new TBadge();
    }

    function getOPCOSet(uint256 set) public pure returns (address[] memory) {
        address[] memory opcoAdrs = new address[](4);
        if (set == 0) {
            opcoAdrs[0] = mkadr("opco1");
            opcoAdrs[1] = mkadr("opco2");
            opcoAdrs[2] = mkadr("opco3");
            opcoAdrs[3] = mkadr("opco4");
        } else if (set == 1) {
            opcoAdrs[0] = mkadr("opco5");
            opcoAdrs[1] = mkadr("opco6");
            opcoAdrs[2] = mkadr("opco7");
            opcoAdrs[3] = mkadr("opco8");
        } else if (set == 2) {
            opcoAdrs[0] = mkadr("opco9");
            opcoAdrs[1] = mkadr("opco10");
            opcoAdrs[2] = mkadr("opco11");
            opcoAdrs[3] = mkadr("opco12");
        } else if (set == 3) {
            opcoAdrs[0] = mkadr("opco13");
            opcoAdrs[1] = mkadr("opco14");
            opcoAdrs[2] = mkadr("opco15");
            opcoAdrs[3] = mkadr("opco16");
        } else if (set == 4) {
            opcoAdrs[0] = mkadr("opco17");
            opcoAdrs[1] = mkadr("opco18");
            opcoAdrs[2] = mkadr("opco19");
            opcoAdrs[3] = mkadr("opco20");
        } else if (set == 5) {
            opcoAdrs[0] = mkadr("opco21");
            opcoAdrs[1] = mkadr("opco22");
            opcoAdrs[2] = mkadr("opco23");
            opcoAdrs[3] = mkadr("opco24");
        }

        return opcoAdrs;
    }

    function getCitizenSet(uint256 set) public pure returns (address[] memory) {
        address[] memory citizenAdrs = new address[](4);
        if (set == 0) {
            citizenAdrs[0] = mkadr("citizen1");
            citizenAdrs[1] = mkadr("citizen2");
            citizenAdrs[2] = mkadr("citizen3");
            citizenAdrs[3] = mkadr("citizen4");
        } else if (set == 1) {
            citizenAdrs[0] = mkadr("citizen5");
            citizenAdrs[1] = mkadr("citizen6");
            citizenAdrs[2] = mkadr("citizen7");
            citizenAdrs[3] = mkadr("citizen8");
        } else if (set == 2) {
            citizenAdrs[0] = mkadr("citizen9");
            citizenAdrs[1] = mkadr("citizen10");
            citizenAdrs[2] = mkadr("citizen11");
            citizenAdrs[3] = mkadr("citizen12");
        } else if (set == 3) {
            citizenAdrs[0] = mkadr("citizen13");
            citizenAdrs[1] = mkadr("citizen14");
            citizenAdrs[2] = mkadr("citizen15");
            citizenAdrs[3] = mkadr("citizen16");
        } else if (set == 4) {
            citizenAdrs[0] = mkadr("citizen17");
            citizenAdrs[1] = mkadr("citizen18");
            citizenAdrs[2] = mkadr("citizen19");
            citizenAdrs[3] = mkadr("citizen20");
        } else if (set == 5) {
            citizenAdrs[0] = mkadr("citizen21");
            citizenAdrs[1] = mkadr("citizen22");
            citizenAdrs[2] = mkadr("citizen23");
            citizenAdrs[3] = mkadr("citizen24");
        }

        return citizenAdrs;
    }

    function getSupplySet(uint256 set) public pure returns (uint256[] memory) {
        uint256[] memory supply = new uint256[](4);
        if (set == 0) {
            supply[0] = 99;
            supply[1] = 99;
            supply[2] = 99;
            supply[3] = 99;
        } else if (set == 1) {
            supply[0] = 10;
            supply[1] = 11;
            supply[2] = 12;
            supply[3] = 14;
        } else if (set == 2) {
            supply[0] = 15;
            supply[1] = 19;
            supply[2] = 4;
            supply[3] = 5;
        } else if (set == 3) {
            supply[0] = 5;
            supply[1] = 5;
            supply[2] = 3;
            supply[3] = 2;
        } else if (set == 4) {
            supply[0] = 1;
            supply[1] = 1;
            supply[2] = 3;
            supply[3] = 4;
        } else if (set == 5) {
            supply[0] = 15;
            supply[1] = 15;
            supply[2] = 15;
            supply[3] = 15;
        }
        return supply;
    }

    function _basicSetup() public {
        address[] memory opcoAdrs = getOPCOSet(0);
        uint256[] memory opcoSupply = getSupplySet(0);
        address[] memory citizenAdrs = getCitizenSet(0);

        vm.prank(opAdr);
        badgeAdmin.addOPCOs(opcoAdrs, opcoSupply);
        vm.prank(opcoAdrs[0]);
        badgeAdmin.addCitizens(citizenAdrs);

        vm.prank(0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84); // deployer address
        badgeAdmin.updateBadgeContract(address(badge));
        badge.updateAdminContract(address(badgeAdmin));
    }

    /** OP CONTROL */

    function testOPControl() public {
        address[] memory opcoAdrs = getOPCOSet(0);
        uint256[] memory opcoSupply = getSupplySet(0);

        address[] memory testAdrs = new address[](1);
        testAdrs[0] = mkadr("alice");

        // Expect to be able to add OPs
        vm.prank(opAdr);
        badgeAdmin.addOPs(testAdrs);

        // Expect to be able to add OPCOs
        vm.prank(opAdr);
        badgeAdmin.addOPCOs(opcoAdrs, opcoSupply);

        // Expect to be able to invalidate an OPCO
        vm.prank(opAdr);
        badgeAdmin.invalidateOPCO(opcoAdrs[0]);
        assertFalse(badgeAdmin.getOPCO(opcoAdrs[0]).valid);

        // Expect to be able to update OP metadata
        vm.prank(opAdr);
        badgeAdmin.updateOPMetadata("");
        assertEq(badgeAdmin.getOP(opAdr).metadata, "");
    }

    function testOPControlReverts() public {
        address[] memory testAdrs = new address[](1);
        testAdrs[0] = mkadr("alice");
        uint256[] memory testSupply = new uint256[](1);
        testSupply[0] = 1;
        address[] memory opcoAdrs = getOPCOSet(0);
        uint256[] memory opcoSupply = getSupplySet(0);

        // Expect revert when adding OPs because address is not an OP
        vm.expectRevert("Error: Invalid OP");
        vm.prank(mkadr("baddy"));
        badgeAdmin.addOPs(testAdrs);

        // Expect revert when adding OPCOs because address is not an OP
        vm.expectRevert("Error: Invalid OP");
        vm.prank(mkadr("notop"));
        badgeAdmin.addOPCOs(opcoAdrs, opcoSupply);

        // Expect revert when adding a duplicate OPCO
        vm.prank(opAdr);
        badgeAdmin.addOPCOs(opcoAdrs, opcoSupply);
        vm.expectRevert("Address already OPCO");
        vm.prank(opAdr);
        badgeAdmin.addOPCOs(opcoAdrs, opcoSupply);

        // Expect revert when adding an OPCO who is already a citizen
        vm.prank(opcoAdrs[0]);
        badgeAdmin.addCitizens(testAdrs);
        vm.expectRevert("Address already Citizen");
        vm.prank(opAdr);
        badgeAdmin.addOPCOs(testAdrs, testSupply);

        // Expect revert when invalidating an OPCO because address is not an OP
        vm.expectRevert("Error: Invalid OP");
        vm.prank(mkadr("stillnotop"));
        badgeAdmin.invalidateOPCO(opcoAdrs[0]);
    }

    /** OPCO CONTROL */

    function testOPCOControl() public {
        _basicSetup();

        address[] memory opcoAdrs = getOPCOSet(0);
        address[] memory citizenAdrs = getCitizenSet(1);

        // Expect to be able to add Citizens
        vm.prank(opcoAdrs[0]);
        badgeAdmin.addCitizens(citizenAdrs);
        assertTrue(badgeAdmin.getOPCO(opcoAdrs[0]).citizens.length > 0);

        // Expect to be able to add metadata
        vm.prank(opcoAdrs[0]);
        badgeAdmin.updateOPCOMetadata(testIPFSHash);
        assertEq(badgeAdmin.getOPCO(opcoAdrs[0]).metadata, testIPFSHash);

        // Expect to be able to remove Citizen
        vm.prank(opcoAdrs[0]);
        badgeAdmin.removeCitizen(citizenAdrs[0]);
        vm.expectRevert(stdError.indexOOBError);
        badgeAdmin.getCitizen(citizenAdrs[0]);

        // Expect to be able to invalidate a citizen
        vm.prank(opcoAdrs[0]);
        badgeAdmin.invalidateCitizen(citizenAdrs[1]);
        assertFalse(badgeAdmin.getCitizen(citizenAdrs[1]).valid);
    }

    function testOPCOControlReverts() public {
        _basicSetup();

        address[] memory opcoAdrs = getOPCOSet(0);

        address[] memory citizenAdrs = getCitizenSet(1);
        address[] memory citizenAdrs2 = getCitizenSet(2);

        // Expect revert when adding Citizens because address is not an OPCO
        vm.prank(mkadr("baddy"));
        vm.expectRevert("Error: Invalid OPCO");
        badgeAdmin.addCitizens(citizenAdrs);

        // Expect revert when an OPCO tries to remove a citizen which doesn't belong to it
        vm.prank(opcoAdrs[1]);
        badgeAdmin.addCitizens(citizenAdrs2);
        vm.prank(opcoAdrs[0]);
        vm.expectRevert("Not OPCO of Citizen");
        badgeAdmin.removeCitizen(citizenAdrs2[0]);

        // Expect revert when citizens > max citizen limit
        address[] memory lotsOfCitizens = new address[](1000);
        vm.expectRevert("Max Citizen limit exceeded");
        vm.prank(opcoAdrs[0]);
        badgeAdmin.addCitizens(lotsOfCitizens);

        // Expect revert when citizens > opco citizen supply
        address[] memory lotsOfCitizens1 = new address[](100);
        vm.expectRevert("Citizen supply exceeded");
        vm.prank(opcoAdrs[0]);
        badgeAdmin.addCitizens(lotsOfCitizens1);

        // Expect revert when new citizen is already a citizen
        vm.prank(opcoAdrs[0]);
        badgeAdmin.addCitizens(citizenAdrs);
        vm.expectRevert("Address already Citizen");
        vm.prank(opcoAdrs[0]);
        badgeAdmin.addCitizens(citizenAdrs);

        // Expect revert when new citizen is already an OPCO
        vm.expectRevert("Address already OPCO");
        vm.prank(opcoAdrs[0]);
        badgeAdmin.addCitizens(opcoAdrs);
    }

    /** CITIZEN CONTROL */

    function testCitizenControl() public {
        _basicSetup();

        address[] memory opcoAdrs = getOPCOSet(0);
        address[] memory citizens = getCitizenSet(0);

        // Expect to be able to mint badge NFT
        vm.prank(citizens[0]);
        badgeAdmin.mint();
        assertEq(badge.balanceOf(citizens[0]), 1);
        assertTrue(badgeAdmin.getCitizen(citizens[0]).minted);
        assertTrue(badgeAdmin.getOPCO(opcoAdrs[0]).minted > 0);

        // Expect to be able to burn badge NFT
        vm.prank(citizens[1]);
        badgeAdmin.mint();
        vm.prank(citizens[1]);
        badgeAdmin.burn(1);
        assertEq(badge.balanceOf(citizens[1]), 0);
        assertFalse(badgeAdmin.getCitizen(citizens[1]).minted);

        // Expect a citizen to be able to update their metadata
        vm.prank(citizens[0]);
        badgeAdmin.updateCitizenMetadata(testIPFSHash);
        assertTrue(badgeAdmin.getCitizen(citizens[0]).metadata == testIPFSHash);
    }

    function testCitizenControlReverts() public {
        _basicSetup();

        address[] memory citizens = getCitizenSet(0);

        // Expect revert when minting if address is not a citizen
        vm.expectRevert("Error: Invalid Citizen");
        vm.prank(mkadr("baddy"));
        badgeAdmin.mint();

        // Expect revert when minting if address already minted a badge NFT
        vm.prank(citizens[0]);
        badgeAdmin.mint();
        vm.expectRevert("Citizen already minted");
        vm.prank(citizens[0]);
        badgeAdmin.mint();

        // Expect revert when burning if address is not badge owner
        vm.prank(citizens[1]);
        badgeAdmin.mint();
        vm.expectRevert("Not badge owner");
        vm.prank(citizens[0]);
        badgeAdmin.burn(1);
    }

    /** VOTE */

    function testVoting() public {
        _basicSetup();

        address[] memory citizens = getCitizenSet(0);

        // Expect to be able to vote
        vm.prank(citizens[0]);
        badgeAdmin.mint();
        vm.prank(citizens[0]);
        badgeAdmin.vote(new bytes(124));

        // Expect to be able to overwrite vote
        vm.prank(citizens[0]);
        badgeAdmin.vote(new bytes(64));
        assertTrue(badgeAdmin.getCitizen(citizens[0]).ballot.length == 64);
    }

    function testVotingReverts() public {
        _basicSetup();

        address[] memory opcoAdrs = getOPCOSet(0);
        address[] memory citizens = getCitizenSet(0);
        address[] memory citizens2 = getCitizenSet(1);

        // Expect revert because voter is not a citizen
        vm.expectRevert("Error: Invalid Citizen");
        vm.prank(mkadr("baddy"));
        badgeAdmin.vote(new bytes(124));

        // Expect revert beacause citizen has invalid status
        vm.prank(opcoAdrs[0]);
        badgeAdmin.addCitizens(citizens2);
        vm.prank(opcoAdrs[0]);
        badgeAdmin.invalidateCitizen(citizens2[0]);
        vm.expectRevert("Error: Invalid Citizen");
        vm.prank(citizens2[0]);
        badgeAdmin.vote(new bytes(124));

        // Expect revert because voter has not minted
        vm.expectRevert("Citizen has not minted");
        vm.prank(citizens[0]);
        badgeAdmin.vote(new bytes(124));

        // Expect revert because voter has delegated to a representative
        vm.prank(citizens[1]);
        badgeAdmin.mint();
        vm.prank(citizens[0]);
        badgeAdmin.mint();
        vm.prank(citizens[0]);
        badgeAdmin.delegate(citizens[1]);
        vm.expectRevert("Delegated to another citizen");
        vm.prank(citizens[0]);
        badgeAdmin.vote(new bytes(124));
    }

    /** DELEGATE */

    function testDelegation() public {
        _basicSetup();

        address[] memory citizens = getCitizenSet(0);

        vm.prank(citizens[2]);
        badgeAdmin.mint();
        vm.prank(citizens[1]);
        badgeAdmin.mint();
        vm.prank(citizens[0]);
        badgeAdmin.mint();

        // Expect to be able to delegate to representative
        vm.prank(citizens[0]);
        badgeAdmin.delegate(citizens[1]);
        assertTrue(badgeAdmin.getCitizen(citizens[0]).delegate == citizens[1]);
        assertTrue(badgeAdmin.getCitizen(citizens[1]).power == 2);

        // Expect to be able to delegate to another citizen
        vm.prank(citizens[0]);
        badgeAdmin.undelegate(citizens[1]);
        vm.prank(citizens[0]);
        badgeAdmin.delegate(citizens[2]);
        assertTrue(badgeAdmin.getCitizen(citizens[0]).delegate == citizens[2]);
        assertTrue(badgeAdmin.getCitizen(citizens[2]).power == 2);
    }

    function testDelegationReverts() public {
        _basicSetup();

        address[] memory opcoAdrs = getOPCOSet(0);
        address[] memory citizens = getCitizenSet(0);
        address[] memory citizens2 = getCitizenSet(1);

        // Expect revert because voter is not a citizen
        vm.expectRevert("Error: Invalid Citizen");
        vm.prank(mkadr("baddy"));
        badgeAdmin.delegate(citizens[0]);

        // Expect revert because citizen has invalid status
        vm.prank(opcoAdrs[0]);
        badgeAdmin.addCitizens(citizens2);
        vm.prank(opcoAdrs[0]);
        badgeAdmin.invalidateCitizen(citizens2[0]);
        vm.expectRevert("Error: Invalid Citizen");
        vm.prank(citizens2[0]);
        badgeAdmin.delegate(citizens[0]);

        // Expect revert because citizen has not minted
        vm.expectRevert("Citizen has not minted");
        vm.prank(citizens[0]);
        badgeAdmin.delegate(citizens[1]);

        // Expect revert because self-delegation not allowed
        vm.expectRevert("Self-delegation not allowed");
        vm.prank(citizens[0]);
        badgeAdmin.delegate(citizens[0]);

        // Expect revert because representative has not minted
        vm.prank(citizens[0]);
        badgeAdmin.mint();
        vm.expectRevert("Delegatee has not minted");
        vm.prank(citizens[0]);
        badgeAdmin.delegate(citizens[1]);

        // Expect revert because representative is not a citizen
        vm.expectRevert("Invalid delegation");
        vm.prank(citizens[0]);
        badgeAdmin.delegate(mkadr("baddy"));
    }

    /** UNDELEGATE */

    function testUndelegate() public {
        _basicSetup();

        address[] memory citizens = getCitizenSet(0);

        vm.prank(citizens[2]);
        badgeAdmin.mint();
        vm.prank(citizens[1]);
        badgeAdmin.mint();
        vm.prank(citizens[0]);
        badgeAdmin.mint();

        // Expect to be able to undelegate
        vm.prank(citizens[0]);
        badgeAdmin.delegate(citizens[1]);
        vm.prank(citizens[0]);
        badgeAdmin.undelegate(citizens[1]);
        assertTrue(badgeAdmin.getCitizen(citizens[0]).delegate == address(0));
        assertTrue(badgeAdmin.getCitizen(citizens[1]).power == 1);
    }

    function testUndelegateReverts() public {
        _basicSetup();

        address[] memory citizens = getCitizenSet(0);

        vm.prank(citizens[2]);
        badgeAdmin.mint();
        vm.prank(citizens[1]);
        badgeAdmin.mint();
        vm.prank(citizens[0]);
        badgeAdmin.mint();

        // Expect to not be able to undelegate who isnt the representative
        vm.prank(citizens[0]);
        badgeAdmin.delegate(citizens[1]);
        vm.expectRevert("Invalid undelegate request");
        vm.prank(citizens[0]);
        badgeAdmin.undelegate(citizens[2]);
    }

    /** MINT */

    function testMinting() public {
        _basicSetup();

        address[] memory opcoAdrs = getOPCOSet(0);
        address[] memory citizens = getCitizenSet(0);

        // Expect to be able to mint
        vm.prank(citizens[0]);
        badgeAdmin.mint();
        assertTrue(badgeAdmin.getCitizen(citizens[0]).minted);
        assertTrue(badge.balanceOf(citizens[0]) == 1);
        assertTrue(badgeAdmin.getOPCO(opcoAdrs[0]).minted == 1);
    }

    function testMintingReverts() public {
        _basicSetup();

        address[] memory opcoAdrs = getOPCOSet(0);
        address[] memory citizens = getCitizenSet(0);

        // Expect revert because minter is not a citizen
        vm.expectRevert("Error: Invalid Citizen");
        vm.prank(mkadr("baddy"));
        badgeAdmin.mint();

        // Expect revert because citizen has invalid status
        vm.prank(opcoAdrs[0]);
        badgeAdmin.invalidateCitizen(citizens[1]);
        vm.prank(citizens[1]);
        vm.expectRevert("Error: Invalid Citizen");
        badgeAdmin.mint();

        // Expect revert because citizen has already minted
        vm.prank(citizens[0]);
        badgeAdmin.mint();
        vm.expectRevert("Citizen already minted");
        vm.prank(citizens[0]);
        badgeAdmin.mint();

        assertTrue(badge.balanceOf(citizens[0]) == 1);
    }

    /** BURN */

    function testBurning() public {
        _basicSetup();

        address[] memory opcoAdrs = getOPCOSet(0);
        address[] memory citizens = getCitizenSet(0);

        vm.prank(citizens[0]);
        badgeAdmin.mint();

        // Expect to be able to burn
        vm.prank(citizens[0]);
        badgeAdmin.burn(0);
        assertTrue(!badgeAdmin.getCitizen(citizens[0]).minted);
        assertTrue(badge.balanceOf(citizens[0]) == 0);
        assertTrue(badgeAdmin.getOPCO(opcoAdrs[0]).minted == 0);
    }

    function testBurningReverts() public {
        _basicSetup();

        address[] memory opcoAdrs = getOPCOSet(0);
        address[] memory citizens = getCitizenSet(0);

        // Expect revert because minter is not a citizen
        vm.expectRevert("Error: Invalid Citizen");
        vm.prank(mkadr("baddy"));
        badgeAdmin.burn(0);

        // Expect revert because citizen has invalid status
        vm.prank(citizens[1]);
        badgeAdmin.mint();
        vm.prank(opcoAdrs[0]);
        badgeAdmin.invalidateCitizen(citizens[1]);
        vm.expectRevert("Error: Invalid Citizen");
        vm.prank(citizens[1]);
        badgeAdmin.burn(0);

        // Expect revert because citizen has not minted
        vm.expectRevert("Not badge owner");
        vm.prank(citizens[0]);
        badgeAdmin.burn(0);

        // Expect revert because citizen not ownerof badge id
        vm.prank(citizens[0]);
        badgeAdmin.mint();
        vm.expectRevert("Not badge owner");
        vm.prank(citizens[0]);
        badgeAdmin.burn(0);
    }

    /** SOULBOUND */

    function testSoulboundReverts() public {
        _basicSetup();

        address[] memory citizens = getCitizenSet(0);

        vm.prank(citizens[0]);
        badgeAdmin.mint();

        // Expect revert transfer because badge is soulbound
        vm.expectRevert("SOULBOUND");
        vm.prank(citizens[0]);
        badge.transferFrom(citizens[0], mkadr("baddy"), 1);

        // Expect revert approve because badge is soulbound
        vm.expectRevert("SOULBOUND");
        vm.prank(citizens[0]);
        badge.approve(mkadr("baddy"), 1);

        // Expect revert approvalForAll because badge is soulbound
        vm.expectRevert("SOULBOUND");
        vm.prank(citizens[0]);
        badge.setApprovalForAll(mkadr("baddy"), true);
    }
}
