// SPDX-License-Identifier: MIT
pragma solidity ^0.6.4;

contract Receiver {
    bool public shouldRevert;
    uint public receivedGas;

    event Received(address sender, uint amount, uint gasLeft);

    receive() external payable {
        require(!shouldRevert, "Receiver is set to revert");
        if (gasleft() > 2500) {
            receivedGas = gasleft();
        }
    }

    function setShouldRevert(bool _value) external {
        shouldRevert = _value;
    }

    function setReceivedGas(uint _value) external {
        receivedGas = _value;
    }
}