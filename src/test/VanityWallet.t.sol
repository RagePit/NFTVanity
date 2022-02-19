// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "ds-test/test.sol";

import {VanityResolver} from "../VanityResolver.sol";
import {VanityWallet} from "../VanityWallet.sol";
import {ExampleContract} from "./utils/ExampleContract.sol";
import {CheatCodes} from "./utils/CheatCodes.sol";

contract VanityWalletTest is DSTest {

    VanityResolver resolver;
    ExampleContract exampleContract;
    CheatCodes hevm = CheatCodes(HEVM_ADDRESS);
    function setUp() public {
        resolver = new VanityResolver();
        exampleContract = new ExampleContract();

        resolver.mint(bytes32(0));
    }

    function testEmptyCall() public {
        VanityWallet vanity = resolver.idToVanity(0);

        //call function from vanity
        bytes memory callData = abi.encode(address(0xbeef), "", 0);
        (bool success, ) = address(vanity).call(callData);
        assertTrue(success);
    }

    function testStaticCall() public {
        VanityWallet vanity = resolver.idToVanity(0);

        //calldata
        bytes memory data = abi.encodeWithSelector(ExampleContract.testStaticCall.selector);
        bytes memory callData = abi.encode(address(exampleContract), data, 0);
        //call function as vanity wallet
        (bool success, bytes memory returnData) = address(vanity).call(callData);
        assertTrue(success);
        uint returnNum = abi.decode(returnData, (uint));
        assertEq(returnNum, exampleContract.testStaticCall());
    }

    function testCall() public {
        VanityWallet vanity = resolver.idToVanity(0);

        bytes memory data = abi.encodeWithSelector(ExampleContract.testStore.selector, 12002);
        bytes memory callData = abi.encode(address(exampleContract), data, 0);

        (bool success, ) = address(vanity).call(callData);
        assertTrue(success);
        assertEq(12002, exampleContract.store());
    }
    
    function testCallNotOwner() public {
        VanityWallet vanity = resolver.idToVanity(0);

        hevm.prank(address(1));

        bytes memory data = abi.encodeWithSelector(ExampleContract.testStore.selector, 12002);
        bytes memory callData = abi.encode(address(exampleContract), data, 0);

        (bool success, ) = address(vanity).call(callData);
        assertTrue(!success);
    }

    function testSendEther() public {
        VanityWallet vanity = resolver.idToVanity(0);

        (bool success, ) = address(vanity).call{value: 1 ether}("");
        assertTrue(success);

        assertEq(address(vanity).balance, 1 ether);
    }
}
