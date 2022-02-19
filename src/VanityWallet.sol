// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import {VanityResolver} from "./VanityResolver.sol";

error NotVanityOwner();
error VanityCallError(bytes);

contract VanityWallet {

    address immutable internal resolver;
    address public owner;

    constructor(address _resolver) {
        resolver = _resolver;
    }
    
    function setOwner(address _owner) public {
        require(msg.sender == resolver);
        owner = _owner;
    }

    fallback(bytes calldata callData) external payable returns(bytes memory){
        (address to, bytes memory data, uint value) = abi.decode(callData, (address, bytes, uint));

        if (msg.sender != owner) revert NotVanityOwner();

        (bool success, bytes memory returnData) = to.call{value: value}(data);
        if (!success) revert VanityCallError(returnData);
        return returnData;
    }
    
    receive() payable external {}

}
