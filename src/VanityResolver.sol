// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import {ERC721} from "solmate/tokens/ERC721.sol";

import {VanityWallet} from "./VanityWallet.sol";

error VanityCreationError();

contract VanityResolver is ERC721("Vanity Wallets", "VAN") {
    
    //      vanity  => owner
    mapping(VanityWallet => address) public vanityToOwner;
    //      id   => vanity
    mapping(uint => VanityWallet) public idToVanity;
    uint public totalSupply;

    //This is fine for now ~11k gas for this view function. Not great
    //Alternatives to explore: 
    //  store bytes in storage (preliminary testing says actually worse)
    //  use an initialization function rather than constructor to remove need for encoding bytes
    //  Using SSTORE2 to store the desired creation code
    function getVanityCreationCode() public view returns(bytes memory) {
        return abi.encodePacked(type(VanityWallet).creationCode, abi.encode(address(this)));
    }

    function mint(bytes32 salt) public payable returns(address vanity) {
        
        bytes memory code = getVanityCreationCode();
        
        assembly { vanity := create2(callvalue(), add(code, 0x20), mload(code), salt) }
        if (vanity == address(0)) revert VanityCreationError();

        VanityWallet castedVanity = VanityWallet(payable(vanity));

        uint id = totalSupply++;
        idToVanity[id] = castedVanity;
        vanityToOwner[castedVanity] = msg.sender;
        
        _mint(msg.sender, id);
    }

    function tokenURI(uint id) public override view returns(string memory) {
        return "";
    }

    //Different structure is the way to go for sure
    //maybe initialization with token id to get rid of vanityToOwner
    function transferFrom(address from, address to, uint id) public override virtual {
        vanityToOwner[idToVanity[id]] = to;
        super.transferFrom(from, to, id);
    }


    function getExpectedAddress(bytes32 salt) public view returns(address) {
        return 
            address(
                uint160(
                    uint256(
                        keccak256(
                            abi.encodePacked(
                                hex'ff',
                                address(this),
                                salt,
                                keccak256(getVanityCreationCode())
                            )
                        )
                    )
                )
            );
    }
}
