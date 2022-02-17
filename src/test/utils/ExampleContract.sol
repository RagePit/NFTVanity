// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

contract ExampleContract {

    uint public store;
    address public addr;

    function testStaticCall() public pure returns(uint) {
        return 1002;
    }

    function testStore(uint i) public {
        store = i;
    }
}
