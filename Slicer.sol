pragma solidity ^0.4.2;

contract Slicer {
    struct Slice {
        uint percentage;
        uint256 balance;
    }
    mapping(address => Slice) public slices;
    address[] public recipients;
    uint numberOfSlices;
    function Slicer(address[] _recipients, uint[] _percentages) {
        numberOfSlices = _recipients.length;
        if (numberOfSlices > 10 || numberOfSlices == 0) {
            throw;
        }
        if (numberOfSlices != _percentages.length) {
            throw;
        }
        uint totalPercentage = 0;
        for (var i = 0; i < numberOfSlices; i++) {
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
        for (var i = 0; i < numberOfSlices; i++) {
            amountHeld += slices[recipients[i]].balance;
        }
        if (amountHeld != this.balance) {
            throw;
        }
    }

    function() payable checkInvariants {
        uint256 amountLeft = msg.value;
        //distribute to all minus one
        for (var i = 0; i < numberOfSlices - 1; i++) {
            var slice = slices[recipients[i]];
            uint256 toGive = msg.value * slice.percentage;
            slice.balance += toGive;
            amountLeft -= toGive;
        }
        //the last one takes the rest
        slices[recipients[i]].balance += amountLeft;
    }
}
