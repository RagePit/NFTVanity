// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import {ERC721} from "solmate/tokens/ERC721.sol";

import {VanityWallet} from "./VanityWallet.sol";

error VanityCreationError();

contract VanityResolver is ERC721("Vanity Wallets", "VAN") {
    
    //      id   => vanity
    mapping(uint => VanityWallet) public idToVanity;
    uint public totalSupply;

    //Alternatives to explore: 
    //  store creation code in storage (preliminary testing says actually worse)
    //  use an initialization function rather than constructor to remove need for encoding bytes
    //  Using SSTORE2 to store the desired creation code
    function mint(bytes32 salt) public payable returns(VanityWallet vanity) {
        vanity = new VanityWallet{salt: salt}(address(this));
        if (address(vanity) == address(0)) revert VanityCreationError();

        uint id = totalSupply++;
        idToVanity[id] = vanity;
        
        vanity.setOwner(msg.sender);
        _mint(msg.sender, id);
    }

    function tokenURI(uint id) public override view returns(string memory) {
        return "";
    }

    //Different structure is the way to go for sure - this is ugly
    function transferFrom(address from, address to, uint id) public override virtual {
        idToVanity[id].setOwner(to);
        super.transferFrom(from, to, id);
    }


    function getExpectedAddress(bytes32 salt) external view returns(address) {
        return 
            address(
                uint160(
                    uint256(
                        keccak256(
                            abi.encodePacked(
                                hex'ff',
                                address(this),
                                salt,
                                keccak256(abi.encodePacked(type(VanityWallet).creationCode, abi.encode(address(this))))
                            )
                        )
                    )
                )
            );
    }
}
