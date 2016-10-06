pragma solidity ^0.4.2;

//Distributes funds according to a pre-established percentage.
//WARNING: This contract is not finished, don't use it!
contract Slicer {
    struct Slice {
        uint percentage;
        uint256 balance;
        bool exists;
    }
    mapping(address => Slice) public slices;
    address[] public recipients;
    uint256 unaccountedTolerance;//on each distribution a small amount might be left behind due to rounding

    function Slicer(address[] _recipients, uint[] _percentages) {
        //10 recipients max to avoid running out of gas
        if (_recipients.length > 10 || _recipients.length < 2) {
            throw;
        }
        if (_recipients.length != _percentages.length) {
            throw;
        }
        uint totalPercentage = 0;
        for (var i = 0; i < _recipients.length; i++) {
            if (slices[_recipients[i]].exists) {
                throw; //no repeated addresses
            }
            if (_percentages[i] == 0 || _percentages[i] > 100) {
                throw;
            }
            slices[_recipients[i]] = Slice(_percentages[i], 0, true);
            totalPercentage += _percentages[i];
        }
        if (totalPercentage != 100) {
            throw;
        }
        unaccountedTolerance = _recipients.length * 100;
        recipients = _recipients;
    }

    modifier checkInvariants() {
        _;
        if (getTotalHeld() > this.balance) {
            throw;
        }
    }

    modifier isRecipient(address entity) {
        if(slices[entity].exists) {
            _;
        } else {
            throw;
        }
    }

    modifier thereAreUnaccountedFunds() {
        uint256 totalHeld = getTotalHeld();
        if (this.balance > totalHeld && this.balance - totalHeld > unaccountedTolerance) {
            _;
        }
    }

    function distributeUnaccountedFunds() private thereAreUnaccountedFunds {
        uint256 amount = this.balance - getTotalHeld();
        for (var i = 0; i < recipients.length; i++) {
            var slice = slices[recipients[i]];
            slice.balance += (amount * slice.percentage) / 100;
        }
    }

    function() payable {}

    function withdrawFor(address entity) isRecipient(entity) checkInvariants {
        distributeUnaccountedFunds();
        uint256 amount = slices[entity].balance;
        slices[msg.sender].balance = 0;
        if(!msg.sender.send(amount)) {
            throw;
        }
    }

    function getTotalHeld() returns(uint256 totalHeld) {
        totalHeld = 0;
        for (var i = 0; i < recipients.length; i++) {
            totalHeld += slices[recipients[i]].balance;
        }
        return totalHeld;
    }
}
