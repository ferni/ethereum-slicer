pragma solidity ^0.4.2;

contract Slicer {
    struct AddressDetails {
        uint percentage;
        uint etherBalance;
    }
    mapping(address => AddressDetails) public slices;
    address[] public beneficiaries;
    function Slicer(address[] _beneficiaries, uint[] _percentages) {
        if (_beneficiaries.length > 10 || _beneficiaries.length == 0) {
            throw;
        }
        if (_beneficiaries.length != _percentages.length) {
            throw;
        }
        uint totalPercentage = 0;
        for (var i = 0; i < _beneficiaries.length; i++) {
            slices[_beneficiaries[i]] = AddressDetails(_percentages[i], 0);
            totalPercentage += _percentages[i];
        }
        if (totalPercentage != 100) {
            throw;
        }
        beneficiaries = _beneficiaries;
    }

    modifier checkInvariants() {
        _;
        uint totalEtherDistributed = 0;
        for (var i = 0; i < beneficiaries.length; i++) {
            totalEtherDistributed += slices[beneficiaries[i]].etherBalance;
        }
    }

    function () payable {

    }
}
