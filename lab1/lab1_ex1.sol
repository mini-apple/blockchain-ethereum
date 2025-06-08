// SPDX-License-Identifier: MIT
pragma solidity ^0.6.4;

contract testContract {

    uint256 value;

    constructor (uint256 _p) public {
        value = _p;
    }

    function setP(uint256 _n) payable public {
        value = _n;
    }

    function setNP(uint256 _n) public {
        value = _n;
    }

    function get () view public returns (uint256) {
        return value;
    }
}