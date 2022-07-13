// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

// import "./../BadgeAdmin.sol";
import { BadgeAdmin } from "../universal/citizen-house/BadgeAdmin.sol";
import { Badge } from "../universal/citizen-house/Badge.sol";
import { Test } from "forge-std/Test.sol";

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

contract BadgeAdminTest is DSTest {
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

    Vm internal constant hevm = Vm(HEVM_ADDRESS);

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
        testOpCoSupply = [3, 10, 5];
        testOpCoSupply1 = [4, 5, 6, 7];

        testOpCoAdrArr2 = [testOpCoAdr1];
        testOpCoSupply2 = [3];
        testCitizenAdrArr = [testAdr1, testAdr2];
        testCitizenAdrArr1 = [testAdr1, testAdr2, testAdr3];

        testOpCoAdrArr3 = [testOpCoAdr1, testOpCoAdr2];
        testOpCoSupply3 = [3, 2];

        testOpCoAdrArr4 = [testAdr4, testAdr5];
        testOpCoSupply4 = [15, 15];

        for (uint256 i = 0; i < 15; i++) {
            alotOfCitizens.push(testBadAdr);
        }
    }

    function _setup() public {
        hevm.prank(opAdr[0]);
        badgeAdmin.addOPCOs(testAdrArr, testOpCoSupply);
        hevm.prank(testOpCoAdr1);
        badgeAdmin.addCitizens(testAdrArr);

        hevm.prank(0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84); // deployer address
        badgeAdmin.updateBadgeContract(address(badge));
        badge.updateAdminContract(address(badgeAdmin));
    }

    function testInvalidAddOPs() public {
        hevm.expectRevert("Error: Sender Not OP");
        hevm.prank(testBadAdr);
        badgeAdmin.addOPs(testAdrArr);
    }

    function testAddOPCOs() public {
        hevm.prank(opAdr[0]);
        badgeAdmin.addOPCOs(testAdrArr, testOpCoSupply);
    }

    function testInvalidAddOPCOs() public {
        hevm.expectRevert("Error: Sender Not OP");
        hevm.prank(0xffffff308539Da3d54F90676b52568515Ed43F39);
        badgeAdmin.addOPCOs(testAdrArr, testOpCoSupply);
    }

    // function testAddingLotsOfCitizens() public {
    //   hevm.prank(opAdr[0]);

    //   badgeAdmin.addOPCOs(testOpCoAdrArr4, testOpCoSupply4);
    //   hevm.prank(testOpCoAdrArr4[1]);
    //   badgeAdmin.addCitizens(alotOfCitizens);
    // }

    // function testGetCitizensGasCost() public {
    //   hevm.prank(opAdr[0]);

    //   badgeAdmin.addOPCOs(testOpCoAdrArr4, testOpCoSupply4);
    //   hevm.prank(testOpCoAdrArr4[1]);
    //   badgeAdmin.addCitizens(alotOfCitizens);
    //   badgeAdmin.getCitizens(0,99);
    // }

    function testInvalidOpCoAddCitizens() public {
        hevm.prank(opAdr[0]);
        badgeAdmin.addOPCOs(testAdrArr, testOpCoSupply);
        hevm.prank(testBadAdr);
        hevm.expectRevert("Error: Sender Not OPCO");
        badgeAdmin.addCitizens(testAdrArr);
    }

    function testContractAddresses() public {
        _setup();
        address a = badge.AdminContract();
        address b = badgeAdmin.BadgeContract();

        console.log(address(badgeAdmin));
        console.log(address(badge));
        console.log(a);
        console.log(b);
    }

    function testMint() public {
        _setup();

        hevm.prank(testAdrArr[0]);
        badgeAdmin.mint();
    }

    function testInvalidAdminMint() public {
        _setup();

        hevm.prank(0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84); // deployer address
        badge.updateAdminContract(0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84);

        hevm.prank(testAdrArr[0]);
        hevm.expectRevert("Error: Sender is not Admin");
        badgeAdmin.mint();
    }

    // function testInvalidMinterMint() public {
    //   _setup();

    //   hevm.expectRevert("Error: Sender Not Citizen");
    //   hevm.prank(testBadAdr);
    //   badge.mint();
    // }

    // function testInvalidSetBaseURI() public {
    //   hevm.expectRevert("Not Op");
    //   hevm.prank(testBadAdr);
    //   badge.setBaseURI("example.com");
    // }

    // function testUpdateOpCoSupply() public {
    //   _setup();

    //   require(badge.getOpCoSupply(testOpCoAdr1) == 3, "Supply Incorrect 1");
    //   hevm.prank(opAdr[0]);
    //   badge.updateOpCoSupply(testOpCoAdr1, 5);
    //   require(badge.getOpCoSupply(testOpCoAdr1) == 5, "Supply Incorrect 2");
    // }

    // function testSetCitizens() public {
    //   hevm.prank(opAdr[0]);
    //   badge.setOpCos(testAdrArr1, testOpCoSupply1);
    //   hevm.prank(testOpCoAdr1);
    //   badge.setCitizens(testAdrArr);
    // }

    // function testSetCitizensInvalidSupply() public {
    //   hevm.prank(opAdr[0]);
    //   badge.setOpCos(testAdrArr1, testOpCoSupply1);
    //   hevm.prank(testOpCoAdr1);
    //   badge.setCitizens(testAdrArr);
    //   hevm.expectRevert("Citizen Count Exceeds Supply");
    //   hevm.prank(testOpCoAdr1);
    //   badge.setCitizens(testAdrArr1);
    // }

    // function testStoredCitizens() public {
    //   hevm.prank(opAdr[0]);
    //   badge.setOpCos(testAdrArr1, testOpCoSupply1);
    //   hevm.prank(testOpCoAdr1);
    //   badge.setCitizens(testAdrArr);
    //   //emit log_address(badge.getCitizenAddress(testOpCoAdr1,0));
    //   for (uint256 i = 0; i < testAdrArr.length; ++i) {
    //     require(badge.isOpCoCitizen(testOpCoAdr1, testAdrArr[i]), "Address Error");
    //   }
    // }

    // function testUpdateCitizen() public {
    //   hevm.prank(opAdr[0]);
    //   badge.setOpCos(testAdrArr1, testOpCoSupply1);
    //   hevm.prank(testOpCoAdr1);
    //   badge.setCitizens(testAdrArr);
    //   hevm.prank(testOpCoAdr1);
    //   badge.updateCitizen(testAdr2,testBadAdr);
    // }

    // function testInvalidUpdateCitizen() public {
    //   hevm.prank(opAdr[0]);
    //   badge.setOpCos(testOpCoAdrArr, testOpCoSupplies);
    //   hevm.prank(testOpCoAdr1);
    //   badge.setCitizens(testAdrArr);
    //   hevm.prank(testOpCoAdr2);
    //   hevm.expectRevert(abi.encodeWithSignature("InvalidOpCo()"));
    //   badge.updateCitizen(testAdr2, testBadAdr);
    // }

    // function testMint2() public {
    //   // Add 1 opco with supply 3 -> Add 2 citizens & mint from citizen 1
    //   hevm.prank(opAdr[0]);
    //   badge.setOpCos(testOpCoAdrArr2, testOpCoSupply2);
    //   hevm.prank(testOpCoAdr1);
    //   badge.setCitizens(testCitizenAdrArr);
    //   console.log("OpCo ", testOpCoAdr1);
    //   console.log("OpCo Supply ",badge.getOpCoSupply(testOpCoAdr1));
    //   console.log("OpCo Allocated ",badge.getOpCoAllocated(testOpCoAdr1));
    //   // console.log("Citizens ", badge.getOpCoCitizens(testOpCoAdr1));
    //   console.log("is Citizen ", badge.isCitizen(testAdr1));
    //   console.log("OpCo Minted ",badge.getOpCoMinted(testOpCoAdr1));
    //   console.log("Citizen OpCo ", badge.getCitizenOpCo(testAdr1));
    //   hevm.prank(testAdr1);
    //   badge.mint();
    // }

    // function testMint3() public {
    //   // Add 2 opco's with supply 3 & 2 ->
    //   // Add 3 citizens from 1st opco & mint from citizen 1 of opco 1
    //   hevm.prank(opAdr[0]);
    //   badge.setOpCos(testOpCoAdrArr2, testOpCoSupply2);
    //   hevm.prank(testOpCoAdr1);
    //   badge.setCitizens(testCitizenAdrArr1);
    //   hevm.prank(testAdr1);
    //   badge.mint();
    // }

    // function testMint4() public {
    //   // Add 2 opco's with supply 3 & 2 ->
    //   // Add 2 citizens from 2nd opco & mint from citizen 2 of opco 2
    //   hevm.prank(opAdr[0]);
    //   badge.setOpCos(testOpCoAdrArr3, testOpCoSupply3);
    //   hevm.prank(testOpCoAdr2);
    //   badge.setCitizens(testCitizenAdrArr);
    //   hevm.prank(testAdr2);
    //   badge.mint();
    // }

    // function testInvalidAlreadyClaimedMint() public {
    //   _setup();

    //   hevm.prank(testAdr1);
    //   badge.mint();
    //   hevm.expectRevert(abi.encodeWithSignature("AlreadyClaimed()"));
    //   hevm.prank(testAdr1);
    //   badge.mint();
    // }

    // function testInvalidBadgeTransfer() public {
    //   _setup();

    //   hevm.prank(testAdr1);
    //   badge.mint();

    //   hevm.expectRevert(abi.encodeWithSignature("Soulbound()"));
    //   badge.transferFrom(testAdr1, 0x0984278a1099bdB47B39FD6B0Ac8Aa83b3000000, 0);
    // }

    // function testBurn() public {
    //   _setup();
    // hevm.prank(testAdr1);

    //   badge.mint();
    //   hevm.prank(testAdr1);
    //   badge.burn(0);
    // }

    // function testInvalidBurn() public {
    //   _setup();

    //   hevm.prank(testAdr1);
    //   badge.mint();
    //   hevm.expectRevert(abi.encodeWithSignature("InvalidBurn()"));
    //   hevm.prank(testAdr2);
    //   badge.burn(0);
    // }

    // function testDelegation() public {
    //   _setup();
    //   hevm.prank(testAdr1);

    //   badge.mint();
    //   hevm.prank(testAdr2);
    //   badge.mint();

    //   hevm.prank(testAdr1);
    //   badge.delegate(testAdr2);
    // }

    // function testInvalidDelegation() public {
    //   _setup();

    //   // -- Un/Comment out any of these to test various cases --
    //   hevm.prank(testAdr1);
    //   badge.mint();
    //   hevm.prank(testAdr2);
    //   badge.mint();
    //   // hevm.prank(testAdr1);
    //   // -- --

    //   hevm.expectRevert("Not Citizen");
    //   badge.delegate(testAdr2);
    // }

    // function testUndelegation() public {
    //   _setup();

    //   hevm.prank(testAdr1);
    //   badge.mint();
    //   hevm.prank(testAdr2);
    //   badge.mint();

    //   hevm.prank(testAdr1);
    //   badge.delegate(testAdr2);

    //   hevm.prank(testAdr1);
    //   badge.undelegate(testAdr2);
    // }

    // function testInvalidUndelegation() public {
    //   _setup();

    //   // -- Un/Comment out any of these to test various cases --
    //   hevm.prank(testAdr1);
    //   badge.mint();
    //   hevm.prank(testAdr2);
    //   badge.mint();
    //   hevm.prank(testAdr1);
    //   badge.delegate(testAdr2);
    //   // -- --

    //   hevm.expectRevert("Not Citizen");
    //   badge.undelegate(testAdr2);
    // }
}
