// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <=0.8.7;

import "./SponsorFunding.sol";

contract CrowdFunding {
     uint private fundingGoal;
     bool private fundable;
     SponsorFunding private sponsor;
    
    constructor(uint _fundingGoal) {
        fundingGoal = _fundingGoal;
        fundable = true;
    }
    
    function getFundingGoal() public view returns (uint) {
        return fundingGoal;
    }
    
    function setFundingGoal(uint _fundingGoal) public {
        fundingGoal = _fundingGoal;
    }
    
    function isFundable() public view returns (bool) {
        return fundable;
    }
    
    function setSponsor(address _sponsor) public {
        sponsor = SponsorFunding(_sponsor);
    }
    
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
    
    function addFunds() public payable {}
    
    receive() external payable {}
}