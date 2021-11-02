// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <=0.8.7;

import "./SponsorFunding.sol";

contract CrowdFunding {
     uint private fundingGoal;
     uint private totalFunded;
     bool private fundable;
     uint private contributorCount;
     address payable distributeFundingContract;
     SponsorFunding sponsor;
     uint sponsorSum;
     
     struct contributorData {
         uint sum;
         string contributorName;
         address payable contributorAddress;
     }
     
     mapping(uint => contributorData) contributors;
     mapping(address => uint) contributorToId;
    
    constructor(uint _fundingGoal) payable {
        fundingGoal = _fundingGoal;
        fundable = true;
        totalFunded = 0;
        contributorCount = 0;
        sponsorSum = 0;
    }
    
    function getFundingGoal() public view returns (uint) {
        return fundingGoal;
    }
    
    function setFundingGoal(uint _fundingGoal) public {
        fundingGoal = _fundingGoal;
    }
    
    function setDistributeFundingContract(address payable _distributeFundingContract) public {
        distributeFundingContract = _distributeFundingContract;
    }
    
    function setSponsor(address payable sponsorAddress) public{
        sponsor = SponsorFunding(sponsorAddress);
        address payable thisAddress = payable(address(this));
        
        if (sponsor.canSponsorContract(thisAddress)) {
            sponsorSum = sponsor.getSponsorshipValue(thisAddress);
        }
    }
    
    function isFundable() public view returns (bool) {
        return fundable;
    }
    
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
    
    function endCrowdFunding() private {
        sponsor.sponsorContract(payable(address(this)));
        distributeFundingContract.transfer(fundingGoal);
    }
    
    function returnFunds(address payable contributorAddress, uint sum) public {
        require(contributors[contributorToId[contributorAddress]].sum < sum, "This contributor has deposited less than the requested eth.");
        require(totalFunded < fundingGoal, "CrowdFunding has ended.");
        
        totalFunded -= sum;
        contributors[contributorToId[contributorAddress]].sum -= sum;
        
        contributorAddress.transfer(sum);
    }
    
    receive() external payable {
        require(totalFunded < fundingGoal, "Funding already achieved.");
        
        uint newTotalFunded = totalFunded + sponsorSum + msg.value;
        uint keptValue = msg.value;
        
        if (newTotalFunded > fundingGoal) {
            keptValue = msg.value - (newTotalFunded - fundingGoal);
            payable(msg.sender).transfer(msg.value - keptValue);
        }
        
        contributors[contributorToId[msg.sender]].sum += msg.value;
        totalFunded += msg.value;
        
    }
}
