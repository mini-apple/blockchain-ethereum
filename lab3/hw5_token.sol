// SPDX-License-Identifier: MIT
pragma solidity ^0.6.4;

contract Token {
    // meta data
    string public name = "VoteToken";
    string public symbol = "VOT";
    uint8  public decimals = 18;

    // ERC20 storage, public 자동 getter 생성
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // Event
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event IssueToken(address indexed _to, uint256 _value);
    event DestructToken(address indexed _from, uint256 _value);

    address public owner;

    constructor(uint256 _initialSupply) public {
        owner = msg.sender;
        totalSupply = _initialSupply;
        balanceOf[owner] = _initialSupply;
        emit Transfer(address(0), owner, totalSupply);
    }

    // ERC20 Standard
    function transfer(address _to, uint256 _value) external returns (bool) {
        require(balanceOf[msg.sender] >= _value, "잔액 부족");
        
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) external returns (bool) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool) {
        require(balanceOf[_from] >= _value, "sender 잔액 부족");
        require(allowance[_from][msg.sender] >= _value, "허용량 초과");

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);
        return true;
    }

    // 토큰 추가 발행 (오너만)
    function issueToken(uint256 _value) external returns (bool) {
        require(msg.sender == owner, "only owner");
        totalSupply += _value;
        balanceOf[owner] += _value;
        emit IssueToken(owner, _value);
        emit Transfer(address(0), owner, _value);
        return true;
    }

    // 토큰 파기 (자기 토큰 파기 가능)
    function destructToken(uint256 _value) external returns (bool) {
        require(balanceOf[msg.sender] >= _value, "잔액 부족");
        totalSupply -= _value;
        balanceOf[msg.sender] -= _value;
        emit DestructToken(msg.sender, _value);
        emit Transfer(msg.sender, address(0), _value);
        return true;
    }
}
