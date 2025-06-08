// SPDX-License-Identifier: MIT
pragma solidity ^0.6.4;

contract Sender {
    address payable public receiver;

    event GasUsed(string label, uint gasStart, uint gasEnd, uint gasUsed);
    event CallResult(string label, bool success);

    constructor(address payable _receiver) public {
        receiver = _receiver;
    }

    function sendWithTransfer() public payable {
        uint gasStart = gasleft();
        receiver.transfer(msg.value);
        uint gasEnd = gasleft();
        emit GasUsed("transfer", gasStart, gasEnd, gasStart - gasEnd);
    }

    function sendWithCall() public payable {
        uint gasStart = gasleft();
        (bool success, ) = receiver.call{value: msg.value}("");
        uint gasEnd = gasleft();
        
        emit CallResult("call-plain", success);
        emit GasUsed("call-plain", gasStart, gasEnd, gasStart - gasEnd);
    }

    function sendWithCallRequire() public payable {
        uint gasStart = gasleft();
        (bool success, ) = receiver.call{value: msg.value}("");
        require(success, "Call failed with requier");
        uint gasEnd = gasleft();

        emit GasUsed("call-require", gasStart, gasEnd, gasStart - gasEnd);
    }
}