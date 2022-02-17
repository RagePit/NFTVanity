// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import {VanityResolver} from "./VanityResolver.sol";

error CallFailed(bytes returnData);
error NotVanityOwner();

contract VanityWallet {

    VanityResolver immutable public resolver;

    constructor(address _resolver) {
        resolver = VanityResolver(_resolver);
    }

    function call(address to, bytes calldata data, uint value) external payable returns(bytes memory) {
        if (msg.sender != resolver.vanityToOwner(this)) revert NotVanityOwner();

        (bool success, bytes memory returnData) = to.call{value: value}(data);

        if (!success) revert CallFailed(returnData);

        return returnData;
    }

    fallback() external payable {}
    receive() external payable {}

}
