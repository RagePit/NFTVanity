// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import {ERC721User} from "solmate/test/utils/users/ERC721User.sol";
import {ERC721} from "solmate/tokens/ERC721.sol";

import {VanityResolver} from "../VanityResolver.sol";
import {VanityWallet} from "../VanityWallet.sol";


contract VanityWalletUser is ERC721User {

    constructor(address resolver) ERC721User(ERC721(resolver)) {}

    function call(VanityWallet wallet, address to, bytes calldata data, uint value) public returns (bytes memory) {
        return wallet.call(to, data, value);
    }

}
