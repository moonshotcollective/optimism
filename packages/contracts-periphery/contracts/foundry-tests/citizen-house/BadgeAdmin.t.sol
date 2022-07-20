// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

// import "./../BadgeAdmin.sol";
import { BadgeAdmin } from "../../universal/citizen-house/BadgeAdmin.sol";
import { Badge } from "../../universal/citizen-house/Badge.sol";
import { Test } from "forge-std/Test.sol";
import { console } from "forge-std/console.sol";

contract TBadge is Badge {
    constructor() Badge("example", "ex", "example.com") {}
}

contract TBadgeAdmin is BadgeAdmin {
    TBadge internal badge;

    address[] adrs = [0xa8B3478A436e8B909B5E9636090F2B15f9B311e7];

    function setUp() public {
        badge = new TBadge();
    }

    constructor() BadgeAdmin(address(badge), 20, 20, 20, adrs) {}
}

contract BadgeAdminTest is Test {
    TBadgeAdmin internal badgeAdmin;
    TBadge internal badge;

    address[] opAdr = [0xa8B3478A436e8B909B5E9636090F2B15f9B311e7];

    address testOpCoAdr1 = 0x0000024FCf3D09DfEe8E7C26f606aC201c505E58;
    address testOpCoAdr2 = 0x2Cf9Fb89BAF95Fa6FdFFe8bA102fA285DE2cA246;

    address[] testOpCoAdrArr = [testOpCoAdr1, testOpCoAdr2];
    uint256[] testOpCoSupplies = [222, 222];

    address testAdr1;
    address testAdr2;
    address testAdr3;
    address testAdr4;
    address testAdr5;

    address testBadAdr;

    address[] testAdrArr;
    uint256[] testOpCoSupply;

    address[] testAdrArr1;
    uint256[] testOpCoSupply1;

    address[] testOpCoAdrArr2;
    uint256[] testOpCoSupply2;
    address[] testCitizenAdrArr;
    address[] testCitizenAdrArr1;

    address[] testOpCoAdrArr3;
    uint256[] testOpCoSupply3;

    address[] testOpCoAdrArr4;
    uint256[] testOpCoSupply4;

    address[] alotOfCitizens;
    uint256[] testOpCoSupplyLots;

    uint256[] testFailSupply;

    bytes32 testIPFSHash;

    function setUp() public {
        badgeAdmin = new TBadgeAdmin();
        badge = new TBadge();

        testAdr1 = 0x0000008735754EDa8dB6B50aEb93463045fc5c55;
        testAdr2 = 0x802999C71263f7B30927F720CF0AC10A76a0494C;
        testAdr3 = 0x802999c71263f7b30927F720cF0AC10a76A0454c;
        testAdr4 = 0xdefbEE7A2a546550eB1ED81A171d6150c0dc3B23;
        testAdr5 = 0xdefecf8a9dFa21843AC9757a75D8DcF07ea9482C;
        testBadAdr = 0x0984278a1099bdB47B39FD6B0Ac8Aa83b3000000;

        testAdrArr = [testOpCoAdr1, testAdr1, testAdr2];
        testAdrArr1 = [testOpCoAdr1, testAdr1, testAdr2, testAdr3];
        testOpCoSupply = [8, 10, 5];
        testOpCoSupply1 = [4, 5, 6, 7];

        testOpCoAdrArr2 = [testOpCoAdr1];
        testOpCoSupply2 = [4];
        testCitizenAdrArr = [testAdr1, testAdr2];
        testCitizenAdrArr1 = [testAdr3];

        testOpCoAdrArr3 = [testOpCoAdr1, testOpCoAdr2];
        testOpCoSupply3 = [3, 2];

        testOpCoAdrArr4 = [testAdr4, testAdr5];
        testOpCoSupply4 = [15, 15];

        testIPFSHash = 0x0170171c23281b16a3c58934162488ad6d039df686eca806f21eba0cebd03486;

        for (uint256 i = 0; i < 15; i++) {
            alotOfCitizens.push(testBadAdr);
        }
    }

    function _setup() public {
        vm.prank(opAdr[0]);
        badgeAdmin.addOPCOs(testAdrArr, testOpCoSupply);
        vm.prank(testOpCoAdr1);
        badgeAdmin.addCitizens(testAdrArr);

        vm.prank(0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84); // deployer address
        badgeAdmin.updateBadgeContract(address(badge));
        badge.updateAdminContract(address(badgeAdmin));
    }

    function testInvalidAddOPs() public {
        vm.expectRevert("Error: Invalid OP");
        vm.prank(testBadAdr);
        badgeAdmin.addOPs(testAdrArr);
    }

    function testAddOPCOs() public {
        vm.prank(opAdr[0]);
        badgeAdmin.addOPCOs(testAdrArr, testOpCoSupply);
    }

    function testInvalidAddOPCOs() public {
        vm.expectRevert("Error: Invalid OP");
        vm.prank(0xffffff308539Da3d54F90676b52568515Ed43F39);
        badgeAdmin.addOPCOs(testAdrArr, testOpCoSupply);
    }

    function testInvalidOpCoAddCitizens() public {
        vm.prank(opAdr[0]);
        badgeAdmin.addOPCOs(testAdrArr, testOpCoSupply);
        vm.prank(testBadAdr);
        vm.expectRevert("Error: Invalid OPCO");
        badgeAdmin.addCitizens(testAdrArr);
    }

    function testMint() public {
        _setup();

        vm.prank(testAdrArr[0]);
        badgeAdmin.mint();
    }

    function testInvalidMint() public {
        _setup();
        vm.expectRevert("Error: Invalid Citizen");
        vm.prank(testBadAdr);
        badgeAdmin.mint();
    }

    function testAlreadyMinted() public {
        _setup();
        vm.prank(testAdrArr[0]);
        badgeAdmin.mint();
        vm.expectRevert("Citizen already minted");
        vm.prank(testAdrArr[0]);
        badgeAdmin.mint();
    }

    function testValidBurn() public {
        _setup();
        vm.prank(testAdrArr[0]);
        badgeAdmin.mint();

        vm.prank(testAdrArr[1]);
        badgeAdmin.mint();

        vm.prank(testAdrArr[1]);
        badgeAdmin.burn(1);
    }

    function testInvalidIdBurn() public {
        _setup();
        vm.prank(testAdrArr[0]);
        badgeAdmin.mint();
        vm.prank(testAdrArr[1]);
        badgeAdmin.mint();
        vm.expectRevert("Not badge owner");
        vm.prank(testAdrArr[0]);
        badgeAdmin.burn(1);
    }

    function testInvalidAdminMint() public {
        _setup();

        vm.prank(0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84); // deployer address
        badge.updateAdminContract(0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84);

        vm.prank(testAdrArr[0]);
        vm.expectRevert("Error: Sender is not Admin");
        badgeAdmin.mint();
    }

    function testUpdateOPCOMetadata() public {
        _setup();

        vm.prank(testOpCoAdr1);
        badgeAdmin.updateOPCOMetadata(testIPFSHash);
    }

    function testUpdateCitizenMetadata() public {
        _setup();

        vm.prank(testAdrArr[0]);
        badgeAdmin.updateCitizenMetadata(testIPFSHash);
    }

    function testCitizenRemoval() public {
        _setup();
        vm.prank(testOpCoAdr1);
        badgeAdmin.removeCitizen(testAdrArr[0]);
    }

    function testBadCitizenRemoval() public {
        _setup();
        vm.prank(opAdr[0]);
        badgeAdmin.addOPCOs(testOpCoAdrArr4, testOpCoSupply4);
        vm.prank(testOpCoAdrArr4[0]);
        vm.expectRevert("Not OPCO of Citizen");
        badgeAdmin.removeCitizen(testAdrArr[0]);
    }

    function testFailDuplicateOPCOs() public {
        _setup();
        vm.prank(opAdr[0]);
        badgeAdmin.addOPCOs(testOpCoAdrArr2, testOpCoSupply2);
    }

    function testFailExceedsCitizenSupply() public {
        _setup();
        vm.prank(testOpCoAdr1);
        badgeAdmin.addCitizens(alotOfCitizens);
    }

    function testFailDuplicateCitizens() public {
        _setup();
        vm.prank(testOpCoAdr1);
        badgeAdmin.addCitizens(testCitizenAdrArr);
        badgeAdmin.addCitizens(testCitizenAdrArr);
    }

    function testInvalidateOPCO() public {
        _setup();
        vm.prank(opAdr[0]);
        badgeAdmin.invalidateOPCO(testOpCoAdr1);
        assertFalse(badgeAdmin.getOPCO(testOpCoAdr1).valid);
    }

    function testFailInvalidateOPCO() public {
        _setup();
        vm.prank(testBadAdr);
        badgeAdmin.invalidateOPCO(testOpCoAdr1);
        assertTrue(badgeAdmin.getOPCO(testOpCoAdr1).valid);
    }

    function testFailInvalidCitizenStatusMint() public {
        _setup();
        vm.prank(testAdrArr[0]);
        badgeAdmin.invalidateCitizen(testCitizenAdrArr[0]);
        vm.prank(testCitizenAdrArr[0]);
        badgeAdmin.mint();
    }

    function testFailInvalidOPCOSatusAddCitizens() public {
        _setup();
        vm.prank(opAdr[0]);
        badgeAdmin.invalidateOPCO(testAdrArr[0]);
        vm.prank(testAdrArr[0]);
        badgeAdmin.addCitizens(testCitizenAdrArr);
    }

    function testVote() public {
        _setup();
        vm.prank(testAdrArr[0]);
        badgeAdmin.mint();
        vm.prank(testAdrArr[0]);
        bytes memory vote = new bytes(124);
        badgeAdmin.vote(vote);
    }

    function testFailVote() public {
        _setup();
        vm.prank(testBadAdr);
        bytes memory vote = new bytes(124);
        badgeAdmin.vote(vote);
    }

    /** VOTE */

    function testVoting() public {
        _setup();

        // Expect to be able to vote
        vm.prank(testAdrArr[0]);
        badgeAdmin.mint();
        vm.prank(testAdrArr[0]);
        badgeAdmin.vote(new bytes(124));

        // Expect to be able to overwrite vote
        vm.prank(testAdrArr[0]);
        badgeAdmin.vote(new bytes(64));
        assertTrue(badgeAdmin.getCitizen(testAdrArr[0]).ballot.length == 64);
    }

    function testVotingReverts() public {
        _setup();

        // Expect revert because voter is not a citizen
        vm.expectRevert("Error: Invalid Citizen");
        vm.prank(testBadAdr);
        badgeAdmin.vote(new bytes(124));

        // Expect revert beacause citizen has invalid status
        vm.prank(testAdrArr[1]);
        badgeAdmin.addCitizens(testCitizenAdrArr1);
        vm.prank(testAdrArr[1]);
        badgeAdmin.invalidateCitizen(testCitizenAdrArr1[0]);
        vm.expectRevert("Error: Invalid Citizen");
        vm.prank(testCitizenAdrArr1[0]);
        badgeAdmin.vote(new bytes(124));

        // Expect revert because voter has not minted
        vm.expectRevert("Citizen has not minted");
        vm.prank(testAdrArr[0]);
        badgeAdmin.vote(new bytes(124));

        // Expect revert because voter has delegated to a representative
        vm.prank(testAdrArr[1]);
        badgeAdmin.mint();
        vm.prank(testAdrArr[0]);
        badgeAdmin.mint();
        vm.prank(testAdrArr[0]);
        badgeAdmin.delegate(testAdrArr[1]);
        vm.expectRevert("Delegated to another citizen");
        vm.prank(testAdrArr[0]);
        badgeAdmin.vote(new bytes(124));
    }

    /** DELEGATE */

    function testDelegation() public {
        _setup();

        vm.prank(testAdrArr[2]);
        badgeAdmin.mint();
        vm.prank(testAdrArr[1]);
        badgeAdmin.mint();
        vm.prank(testAdrArr[0]);
        badgeAdmin.mint();

        // Expect to be able to delegate to representative
        vm.prank(testAdrArr[0]);
        badgeAdmin.delegate(testAdrArr[1]);
        assertTrue(badgeAdmin.getCitizen(testAdrArr[0]).representative == testAdrArr[1]);
        assertTrue(badgeAdmin.getCitizen(testAdrArr[1]).delegations == 2);

        // Expect to be able to delegate to another citizen
        vm.prank(testAdrArr[0]);
        badgeAdmin.undelegate(testAdrArr[1]);
        vm.prank(testAdrArr[0]);
        badgeAdmin.delegate(testAdrArr[2]);
        assertTrue(badgeAdmin.getCitizen(testAdrArr[0]).representative == testAdrArr[2]);
        assertTrue(badgeAdmin.getCitizen(testAdrArr[2]).delegations == 2);
    }

    function testDelegationReverts() public {
        _setup();

        // Expect revert because voter is not a citizen
        vm.expectRevert("Error: Invalid Citizen");
        vm.prank(testBadAdr);
        badgeAdmin.delegate(testAdrArr[0]);

        // Expect revert because citizen has invalid status
        vm.prank(testAdrArr[1]);
        badgeAdmin.addCitizens(testCitizenAdrArr1);
        vm.prank(testAdrArr[1]);
        badgeAdmin.invalidateCitizen(testCitizenAdrArr1[0]);
        vm.expectRevert("Error: Invalid Citizen");
        vm.prank(testCitizenAdrArr1[0]);
        badgeAdmin.delegate(testAdrArr[0]);

        // Expect revert because citizen has not minted
        vm.expectRevert("Citizen has not minted");
        vm.prank(testAdrArr[0]);
        badgeAdmin.delegate(testAdrArr[1]);

        // Expect revert because self-delegation not allowed
        vm.expectRevert("Self-delegation not allowed");
        vm.prank(testAdrArr[0]);
        badgeAdmin.delegate(testAdrArr[0]);

        // Expect revert because representative has not minted
        vm.prank(testAdrArr[0]);
        badgeAdmin.mint();
        vm.expectRevert("Delegated has not minted");
        vm.prank(testAdrArr[0]);
        badgeAdmin.delegate(testAdrArr[1]);

        // Expect revert because representative is not a citizen
        vm.expectRevert("Invalid delegation");
        vm.prank(testAdrArr[0]);
        badgeAdmin.delegate(testBadAdr);
    }

    /** UNDELEGATE */

    function testUndelegate() public {
        _setup();

        vm.prank(testAdrArr[2]);
        badgeAdmin.mint();
        vm.prank(testAdrArr[1]);
        badgeAdmin.mint();
        vm.prank(testAdrArr[0]);
        badgeAdmin.mint();

        // Expect to be able to undelegate
        vm.prank(testAdrArr[0]);
        badgeAdmin.delegate(testAdrArr[1]);
        vm.prank(testAdrArr[0]);
        badgeAdmin.undelegate(testAdrArr[1]);
        assertTrue(badgeAdmin.getCitizen(testAdrArr[0]).representative == address(0));
        assertTrue(badgeAdmin.getCitizen(testAdrArr[1]).delegations == 1);
    }

    function testUndelegateReverts() public {
        _setup();

        vm.prank(testAdrArr[2]);
        badgeAdmin.mint();
        vm.prank(testAdrArr[1]);
        badgeAdmin.mint();
        vm.prank(testAdrArr[0]);
        badgeAdmin.mint();

        // Expect to not be able to undelegate who isnt the representative
        vm.prank(testAdrArr[0]);
        badgeAdmin.delegate(testAdrArr[1]);
        vm.expectRevert("Invalid undelegate request");
        vm.prank(testAdrArr[0]);
        badgeAdmin.undelegate(testAdrArr[2]);
    }

    /** MINT */

    function testMinting() public {
        _setup();

        // Expect to be able to mint
        vm.prank(testAdrArr[0]);
        badgeAdmin.mint();
        assertTrue(badgeAdmin.getCitizen(testAdrArr[0]).minted);
        assertTrue(badge.balanceOf(testAdrArr[0]) == 1);
        assertTrue(badgeAdmin.getOPCO(testOpCoAdr1).minted == 1);
    }

    function testMintingReverts() public {
        _setup();

        // Expect revert because minter is not a citizen
        vm.expectRevert("Error: Invalid Citizen");
        vm.prank(testBadAdr);
        badgeAdmin.mint();

        // Expect revert because citizen has invalid status
        vm.prank(testOpCoAdr1);
        badgeAdmin.invalidateCitizen(testAdrArr[1]);
        vm.prank(testAdrArr[1]);
        vm.expectRevert("Error: Invalid Citizen");
        badgeAdmin.mint();

        // Expect revert because citizen has already minted
        vm.prank(testAdrArr[0]);
        badgeAdmin.mint();
        vm.expectRevert("Citizen already minted");
        vm.prank(testAdrArr[0]);
        badgeAdmin.mint();

        assertTrue(badge.balanceOf(testAdrArr[0]) == 1);
    }

    /** BURN */

    function testBurning() public {
        _setup();

        vm.prank(testAdrArr[0]);
        badgeAdmin.mint();

        // Expect to be able to burn
        vm.prank(testAdrArr[0]);
        badgeAdmin.burn(0);
        assertTrue(!badgeAdmin.getCitizen(testAdrArr[0]).minted);
        assertTrue(badge.balanceOf(testAdrArr[0]) == 0);
        assertTrue(badgeAdmin.getOPCO(testOpCoAdr1).minted == 0);
    }

    function testBurningReverts() public {
        _setup();

        // Expect revert because minter is not a citizen
        vm.expectRevert("Error: Invalid Citizen");
        vm.prank(testBadAdr);
        badgeAdmin.burn(0);

        // Expect revert because citizen has invalid status
        vm.prank(testAdrArr[1]);
        badgeAdmin.mint();
        vm.prank(testOpCoAdr1);
        badgeAdmin.invalidateCitizen(testAdrArr[1]);
        vm.expectRevert("Error: Invalid Citizen");
        vm.prank(testAdrArr[1]);
        badgeAdmin.burn(0);

        // Expect revert because citizen has not minted
        vm.expectRevert("Not badge owner");
        vm.prank(testAdrArr[0]);
        badgeAdmin.burn(0);

        // Expect revert because citizen not ownerof badge id
        vm.prank(testAdrArr[0]);
        badgeAdmin.mint();
        vm.expectRevert("Not badge owner");
        vm.prank(testAdrArr[0]);
        badgeAdmin.burn(0);
    }
}
