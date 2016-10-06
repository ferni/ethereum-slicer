pragma solidity ^0.4.2;

contract Slicer {
    struct Slice {
        uint percentage;
        uint256 balance;
        bool exists;
    }
    mapping(address => Slice) public slices;
    address[] public recipients;
    function Slicer(address[] _recipients, uint[] _percentages) {
        if (_recipients.length > 10 || _recipients.length == 0) {
            throw;
        }
        if (_recipients.length != _percentages.length) {
            throw;
        }
        uint totalPercentage = 0;
        for (var i = 0; i < _recipients.length; i++) {
            slices[_recipients[i]] = Slice(_percentages[i] / 100, 0, true);
            totalPercentage += _percentages[i];
        }
        if (totalPercentage != 100) {
            throw;
        }
        recipients = _recipients;
    }

    modifier checkInvariants() {
        _;
        uint256 amountHeld = 0;
        for (var i = 0; i < recipients.length; i++) {
            amountHeld += slices[recipients[i]].balance;
        }
        if (amountHeld != this.balance) {
            throw;
        }
    }

    modifier onlyRecipients() {
        if(slices[msg.sender].exists) {
            _;
        } else {
            throw;
        }
    }

    function() payable checkInvariants {
        uint256 amountLeft = msg.value;
        //distribute to all minus one
        for (var i = 0; i < recipients.length - 1; i++) {
            var slice = slices[recipients[i]];
            uint256 toGive = msg.value * slice.percentage;
            slice.balance += toGive;
            amountLeft -= toGive;
        }
        //the last one takes the rest
        slices[recipients[i]].balance += amountLeft;
    }

    function withdraw() onlyRecipients {
        uint256 amount = slices[msg.sender].balance;
        slices[msg.sender].balance = 0;
        if(!msg.sender.send(amount)) {
            throw;
        }
    }
}
