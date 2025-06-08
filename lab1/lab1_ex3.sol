// SPDX-License-Identifier: MIT
pragma solidity ^0.6.4;

contract Donation {
    address owner;
    event fundMoved(address _to);
    modifier onlyowner { require(msg.sender == owner); _; }
    address[] _giver;
    uint[] _values;

    constructor() public {
        owner = msg.sender;
    }

    struct ActionLog {
        address sender;
        string action;
        uint value;
        uint timestamp;
    }
    ActionLog[] private logs;

    function donate() public payable {
        addGiver(msg.value);

        logs.push(ActionLog({
            sender: msg.sender,
            action: "donate",
            value: msg.value,
            timestamp: block.timestamp
        }));
    }

    function moveFund(address payable _to) onlyowner public {
        uint balance = address(this).balance;
        if (0 <= balance) {
            if (_to.send(balance)) {
                emit fundMoved(_to);

                logs.push(ActionLog({
                    sender: msg.sender,
                    action: "moveFund",
                    value: balance,
                    timestamp: block.timestamp
                }));
            }
            else {
                revert();
            }
        }
        else {
            revert();
        }
    }

    function addGiver(uint _amount) internal {
        _giver.push(msg.sender) ;
        _values.push(_amount);
    }

    function getLogCount() public view returns (uint) {
        return logs.length;
    }

    function getLog(uint index) 
        public
        view
        returns (address sender, string memory action, uint value, uint timestamp)
    {
        require(index < logs.length, "Index out of range");
        ActionLog memory logEntry = logs[index];
        return (
            logEntry.sender,
            logEntry.action,
            logEntry.value,
            logEntry.timestamp
        );
    }
}