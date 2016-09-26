pragma solidity ^0.4.2;

contract Slicer {
    struct Slice {
        uint percentage;
        uint256 balance;
    }
    mapping(address => Slice) public slices;
    address[] public beneficiaries;
    uint firstBeneficiary = 0;
    uint numberOfSlices;
    function Slicer(address[] _beneficiaries, uint[] _percentages) {
        numberOfSlices = _beneficiaries.length;
        if (numberOfSlices > 10 || numberOfSlices == 0) {
            throw;
        }
        if (numberOfSlices != _percentages.length) {
            throw;
        }
        uint totalPercentage = 0;
        for (var i = 0; i < numberOfSlices; i++) {
            slices[_beneficiaries[i]] = Slice(_percentages[i] / 100, 0);
            totalPercentage += _percentages[i];
        }
        if (totalPercentage != 100) {
            throw;
        }
        beneficiaries = _beneficiaries;
    }

    modifier checkInvariants() {
        _;
        uint totalWeiDistributed = 0;
        for (var i = 0; i < numberOfSlices; i++) {
            totalWeiDistributed += slices[beneficiaries[i]].balance;
        }
        if (totalWeiDistributed != this.balance) {
            throw;
        }
    }

    function() payable checkInvariants {
        var index = firstBeneficiary;
        uint256 amountLeft = msg.value;

        //distribute to all minus one
        for (var given = 0; given < numberOfSlices - 1; given++) {
            var slice = slices[beneficiaries[index]];
            uint256 toGive = msg.value * slice.percentage;
            slice.balance += toGive;
            amountLeft -= toGive;
            index++;
            if (index > numberOfSlices - 1) {
                index = 0;
            }
        }
        //the last one takes the rest
        slices[beneficiaries[index]].balance += amountLeft;

        //rotate beneficiaries so rounding errors matter less
        firstBeneficiary++;
        if (firstBeneficiary > numberOfSlices - 1) {
            firstBeneficiary = 0;
        }
    }
}
