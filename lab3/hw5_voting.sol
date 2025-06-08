// SPDX-License-Identifier: MIT
pragma solidity ^0.6.4;

import "lab3/hw5_token.sol";

contract Voting {
    Token public token;         // 투표권으로 사용할 ERC20 토큰
    address public owner;       // 컨트랙트 소유자
    uint256 public tokenPrice;  // 1토큰(=1표) 가격 (wei 단위)
    bool public ended;          // 투표 종료 여부

    // 후보자 구조체
    struct Candidate {
        string name;       // 후보자 이름
        uint256 voteCount; // 득표 수
    }

    // 후보자 관리
    mapping(bytes32 => Candidate) public candidates;
    bytes32[] public candidateList;

    // 이벤트
    event CandidateRegistered(string _name);
    event Bought(address indexed _buyer, uint256 _amount);
    event Voted(address indexed _voter, string _candidate, uint256 _votes);
    event PriceChanged(uint256 _oldPrice, uint256 _newPrice);
    event VotingEnded(uint256 _totalFunds);

    // 권한 제어
    modifier onlyOwner() {
        require(msg.sender == owner, "only owner");
        _;
    }

    modifier notEnded() {
        require(!ended, "voting ended");
        _;
    }

    constructor(Token _token, uint256 _tokenPrice) public {
        owner = msg.sender;
        token = _token;
        tokenPrice = _tokenPrice;
        ended = false;
    }

    /// 후보자 등록 (오너만, 투표 마감 전)
    function registerCandidate(string calldata _name) external onlyOwner notEnded {
        bytes32 key = keccak256(abi.encodePacked(_name));
        require(bytes(candidates[key].name).length == 0, "이미 등록된 후보");
        
        candidates[key] = Candidate({ name: _name, voteCount: 0 });
        candidateList.push(key);
        
        emit CandidateRegistered(_name);
    }

    // 투표권(토큰) 구매
    function buyTokens(uint256 _numTokens) external payable notEnded {
        require(msg.value == _numTokens * tokenPrice, "잘못된 이더 금액 전송");
        require(token.balanceOf(address(this)) >= _numTokens, "컨트랙트에 토큰 잔액 부족");
        require(token.transfer(msg.sender, _numTokens), "토큰 전송 실패");

        emit Bought(msg.sender, _numTokens);
    }

    // 투표 (1표당 1토큰 소모)
    function vote(string calldata _name, uint256 _numVotes) external notEnded {
        bytes32 key = keccak256(abi.encodePacked(_name));
        require(bytes(candidates[key].name).length != 0, "해당 후보자 없음");

        require(token.allowance(msg.sender, address(this)) >= _numVotes, "insufficient allowance");
        require(token.transferFrom(msg.sender, address(this), _numVotes), "transferFrom failed");

        require(token.destructToken(_numVotes), "burn failed");

        candidates[key].voteCount += _numVotes;
        emit Voted(msg.sender, candidates[key].name, _numVotes);
    }

    // 특정 후보 득표수 조회
    function getVoteCount(string calldata _name) external view returns (uint256) {
        bytes32 key = keccak256(abi.encodePacked(_name));
        return candidates[key].voteCount;
    }

    // 토큰 가격 변경 (오너만, 투표 전)
    function changePrice(uint256 _newPrice) external onlyOwner notEnded {
        uint256 old = tokenPrice;
        tokenPrice = _newPrice;
        emit PriceChanged(old, _newPrice);
    }

    // 투표권(토큰) 양도
    function transferVotingRights(address _to, uint256 _amount) external notEnded {
        require(token.transfer(_to, _amount), "transfer failed");
    }

    // 투표 종료 및 정산 (오너만)
    function endVoting() external onlyOwner notEnded {
        ended = true;
        // 남은 토큰을 오너에게 반환
        uint256 remaining = token.balanceOf(address(this));
        if (remaining > 0) {
            require(token.transfer(owner, remaining), "return tokens failed");
        }
        // 모인 이더를 오너에게 전송
        uint256 balance = address(this).balance;
        payable(owner).transfer(balance);
        emit VotingEnded(balance);
    }
}
