// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <=0.8.7;

import "./SponsorFunding.sol";

contract CrowdFunding {
     uint private fundingGoal;
     uint private totalFunded;
     bool private fundable;
     uint private sponsorCount;
     address payable distributeFundingContract;
     
     struct sponsorData {
         uint sum;
         string sponsorName;
         address payable sponsorAddress;
     }
     
     mapping(uint => sponsorData) sponsors;
     mapping(address => uint) sponsorToId;
    
    constructor(uint _fundingGoal, address payable _distributeFundingContract) {
        fundingGoal = _fundingGoal;
        fundable = true;
        totalFunded = 0;
        sponsorCount = 0;
        distributeFundingContract = _distributeFundingContract;
    }
    
    function getFundingGoal() public view returns (uint) {
        return fundingGoal;
    }
    
    function setFundingGoal(uint _fundingGoal) public {
        fundingGoal = _fundingGoal;
    }
    
    function registerSponsor(address payable sponsorAddress, string memory name) public {
        sponsors[sponsorCount] = sponsorData({
            sum: 0,
            sponsorName: name,
            sponsorAddress: sponsorAddress
        });
        sponsorToId[sponsorAddress] = sponsorCount++;
    }
    
    function isFundable() public view returns (bool) {
        return fundable;
    }
    
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
    
    function endCrowdFunding() private {
        for (uint sponsorId = 0; sponsorId < sponsorCount; ++sponsorId) {
            SponsorFunding sponsorContract = SponsorFunding(sponsors[sponsorId].sponsorAddress);
            
            sponsorContract.sponsorContract(payable(address(this)));
        }
        
        distributeFundingContract.transfer(fundingGoal);
    }
    
    function returnFunds(address payable sponsorAddress, uint sum) public {
        require(sponsors[sponsorToId[sponsorAddress]].sum < sum, "This sponsor has deposited less than the requested eth.");
        require(totalFunded < fundingGoal, "CrowdFunding has ended.");
        
        totalFunded -= sum;
        sponsors[sponsorToId[sponsorAddress]].sum -= sum;
        
        sponsorAddress.transfer(sum);
    }
    
    receive() external payable {
        uint fundingGoalLeft = fundingGoal - totalFunded - msg.value;
        if (fundingGoalLeft < 0) {
            sponsors[sponsorToId[msg.sender]].sum += msg.value + fundingGoalLeft;
            totalFunded = fundingGoal;
            sponsors[sponsorToId[msg.sender]].sponsorAddress.transfer(fundingGoalLeft);
        }
        
        require(totalFunded < fundingGoal, "Funding already achieved.");
        sponsors[sponsorToId[msg.sender]].sum += msg.value;
        totalFunded += msg.value;
        
    }
}
