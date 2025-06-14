// SPDX-License-Identifier: MIT
pragma solidity ^0.6.4;

contract PacktToken {
    string public name = "Test ERC20 Token";
    string public symbol = "TET";

    uint256 public totalSupply;
    uint8 public decimals;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    mapping(address => uint256) public balanceOf;

    constructor(uint256 _initSupply) public {
        balanceOf[msg.sender] = _initSupply;
        totalSupply = _initSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    mapping(address => mapping(address => uint256)) public allowance;

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);
        
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    event Approval(address indexed _owner, address indexed _spender, uint value);

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
}