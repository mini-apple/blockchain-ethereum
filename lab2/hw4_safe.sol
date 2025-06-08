// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Safe {
    bool private locked;
    uint256 public withdrawlLimit = 1 ether;
    mapping(address => uint256) public balances;

    // mapping을 쓰도록 수정
    struct AuditStats {
        uint8 lastAccess;
        uint248 accessCount;
    }
    mapping(address => AuditStats) private auditMap;

    function depositFunds() external payable {
        balances[msg.sender] += msg.value;
    }

    // 1. Check -> Effect -> Interaction 순서로 코드패턴,
    // 2. transfer()를 사용하여 고정 2,300 가스만 전달하도록 함 (call에 비해 안전, 자동 revert)
    function withdrawFunds(uint256 _weiToWithdraw) public {
        // 1. 재진입 가드
        require(!locked, "Reentrant");
        locked = true;

        // 2. Check: 잔액 및 한도 검사
        require(balances[msg.sender] >= _weiToWithdraw, "Not enough balances");
        require(_weiToWithdraw <= withdrawlLimit, "Too large withdraw");

        // 3. Effect: 상태 먼저 업데이트
        balances[msg.sender] -= _weiToWithdraw;

        // 4. Interaction: 이더 전송 (transfer는 실패 시 자동 revert)
        msg.sender.transfer(_weiToWithdraw);

        // 5. 재진입 가드 해제
        locked = false;
    }

    // AuditStats 취약점 보완
    function refreshAuditStats() public {
        // 주소별로 AuditStats를 저장할 mapping에서 가져오도록 수정
        AuditStats storage stats = auditMap[msg.sender];

        stats.lastAccess = uint8(now % 256);   // 마지막 접근 시간의 일부를 저장
        stats.accessCount += 1;
    }

    function isLocked() public view returns (bool) {
        return locked;
    }
}