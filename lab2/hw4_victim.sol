// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Victim {
    bool private locked;
    uint256 public withdrawlLimit = 1 ether;
    mapping(address => uint256) public balances;

    struct AuditStats {
        uint8 lastAccess;
        uint248 accessCount;
    }

    function depositFunds() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdrawFunds(uint256 _weiToWithdraw) public {
        require(!locked, "Reenterant");
        locked = true;
        
        require(balances[msg.sender] >= _weiToWithdraw, "Not enough balances");
        require(_weiToWithdraw <= withdrawlLimit, "Too large withdraw");
        require(msg.sender.call.value(_weiToWithdraw)(), "Transfer failed");
        
        balances[msg.sender] -= _weiToWithdraw;
        locked = false;
    }

    function refreshAuditStats() public {
        AuditStats storage stats;
        stats.lastAccess = 0;
        stats.accessCount += 1;
    }

    function isLocked() public view returns (bool) {
        return locked;
    }
}