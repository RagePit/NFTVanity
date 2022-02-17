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

    function testStaticCall() public {
        VanityWallet vanity = resolver.idToVanity(0);

        //calldata
        bytes memory data = abi.encodeWithSelector(ExampleContract.testStaticCall.selector);
        //call function from vanity
        bytes memory returnData = vanity.call(address(exampleContract), data, 0);

        uint returnNum = abi.decode(returnData, (uint));
        assertEq(returnNum, exampleContract.testStaticCall());
    }

    function testCall() public {
        VanityWallet vanity = resolver.idToVanity(0);

        bytes memory data = abi.encodeWithSelector(ExampleContract.testStore.selector, 12002);
        vanity.call(address(exampleContract), data, 0);

        assertEq(12002, exampleContract.store());
    }
    
    function testFailCallNotOwner() public {
        VanityWallet vanity = resolver.idToVanity(0);

        hevm.prank(address(1));

        bytes memory data = abi.encodeWithSelector(ExampleContract.testStore.selector, 12002);
        vanity.call(address(exampleContract), data, 0);
    }    
}
