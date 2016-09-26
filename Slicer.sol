pragma solidity ^0.4.2;

contract Slicer {
    struct Slice {
        uint percentage;
        uint256 balance;
    }
    mapping(address => Slice) public slices;
    address[] public recepients;
    uint numberOfSlices;
    function Slicer(address[] _recepients, uint[] _percentages) {
        numberOfSlices = _recepients.length;
        if (numberOfSlices > 10 || numberOfSlices == 0) {
            throw;
        }
        if (numberOfSlices != _percentages.length) {
            throw;
        }
        uint totalPercentage = 0;
        for (var i = 0; i < numberOfSlices; i++) {
            slices[_recepients[i]] = Slice(_percentages[i] / 100, 0);
            totalPercentage += _percentages[i];
        }
        if (totalPercentage != 100) {
            throw;
        }
        recepients = _recepients;
    }

    modifier checkInvariants() {
        _;
        uint amountHeld = 0;
        for (var i = 0; i < numberOfSlices; i++) {
            amountHeld += slices[recepients[i]].balance;
        }
        if (amountHeld != this.balance) {
            throw;
        }
    }

    function() payable checkInvariants {
        uint256 amountLeft = msg.value;
        //distribute to all minus one
        for (var i = 0; i < numberOfSlices - 1; i++) {
            var slice = slices[recepients[i]];
            uint256 toGive = msg.value * slice.percentage;
            slice.balance += toGive;
            amountLeft -= toGive;
        }
        //the last one takes the rest
        slices[recepients[i]].balance += amountLeft;
    }
}
