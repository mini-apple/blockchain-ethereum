// SPDX-License-Identifier: MIT
pragma solidity ^0.6.4;

import "./lab3_ex1_packtToken.sol";

contract TokenSale {
    PacktToken public tokenContract;
    uint256 public tokenPrice;
    uint256 public tokenSold;
    address owner;

    constructor(PacktToken _tokenContract, uint256 _tokenPrice) public {
        owner = msg.sender;
        tokenContract = _tokenContract;
        tokenPrice = _tokenPrice;
    }

    event Sell(address indexed _buyer, uint256 indexed _amount);

    function buyToken(uint256 _numberOfTokens) public payable {
        require(msg.value == _numberOfTokens * tokenPrice * 1 ether);
        require(tokenContract.balanceOf(address(this)) >= _numberOfTokens);
        tokenSold += _numberOfTokens;
        emit Sell(msg.sender, _numberOfTokens);
        require(tokenContract.transfer(msg.sender, _numberOfTokens));
    }

    function endSale() public {
        require(msg.sender == owner);
        require(tokenContract.transfer(owner, tokenContract.balanceOf(address(this))));
        msg.sender.transfer(address(this).balance);
    }
}