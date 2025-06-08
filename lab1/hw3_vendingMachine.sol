// SPDX-License-Identifier: MIT
pragma solidity ^0.6.4;

contract VendingMachine {
    address public owner;
    modifier onlyOwner() { require(msg.sender == owner, "Not owner"); _; }

    // 구매 로그 구조체
    struct Log {
        address user;
        uint256 amount;
    }
    Log[] private logs;


    constructor() public {
        owner = msg.sender;
    }

    // 음료별 구매
    function getSoda(uint256 num) external payable returns (string memory) {
        uint256 price = 1 ether * num;
        require(msg.value >= price, "결제를 위한 ETH 부족");
        uint256 change = msg.value - price;
        if (change > 0) {
            payable(msg.sender).transfer(change);
        }
        logs.push(Log(msg.sender, msg.value));
        return "결제 완료";
    }

    function getJuice(uint256 num) external payable returns (string memory) {
        uint256 price = 2 ether * num;
        require(msg.value >= price, "결제를 위한 ETH 부족");
        uint256 change = msg.value - price;
        if (change > 0) {
            payable(msg.sender).transfer(change);
        }
        logs.push(Log(msg.sender, msg.value));
        return "결제 완료";
    }

    function getWater(uint256 num) external payable returns (string memory) {
        uint256 price = 3 ether * num;
        require(msg.value >= price, "결제를 위한 ETH 부족");
        uint256 change = msg.value - price;
        if (change > 0) {
            payable(msg.sender).transfer(change);
        }
        logs.push(Log(msg.sender, msg.value));
        return "결제 완료";
    }

    function getLogs()
        external
        view
        onlyOwner
        returns (address[] memory users, uint256[] memory amounts)
    {
        uint256 len = logs.length;
        users   = new address[](len);
        amounts = new uint256[](len);
        for (uint256 i = 0; i < len; i++) {
            users[i]   = logs[i].user;
            amounts[i] = logs[i].amount;
        }
    }

    // 컨트랙트 잔액 출금
    function withdraw() external onlyOwner {
        uint256 bal = address(this).balance;
        require(bal > 0, "No funds to withdraw");
        payable(owner).transfer(bal);
    }
}
