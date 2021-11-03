// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <=0.8.7;

import "./SponsorFunding.sol";

contract CrowdFunding {
     uint private fundingGoal;
     uint private totalFunded;
     bool private fundable;
     address payable distributeFundingContract;
     SponsorFunding sponsor;
     
     event ContributorFunded(uint sum);
     event SponsorRegistered(address payable);
     event CrowdFundingEnded(uint sentSum);
     
     struct contributorData {
         uint sum;
         string contributorName;
         address payable contributorAddress;
     }
     
     mapping(address => contributorData) contributors;

    constructor(uint _fundingGoal) payable {
        fundingGoal = _fundingGoal;
        totalFunded = 0;
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
    
    function contribute() public payable {
        require(isFundable(), "Funding already achieved.");
        
        // uint sponsorSum = getSponsorValue();
        // uint newTotalFunded = totalFunded + sponsorSum + msg.value;
        // uint keptValue = msg.value;
        
        // if (newTotalFunded > fundingGoal) {
        //     keptValue = msg.value - (newTotalFunded - fundingGoal);
        //     payable(msg.sender).transfer(msg.value - keptValue);
        // }
        
        contributors[msg.sender].sum += msg.value;
        totalFunded += msg.value;
        
        // if (totalFunded + sponsorSum >= fundingGoal) {
        //     endCrowdFunding();
        // }
        emit ContributorFunded(msg.value);
    }
    
    function setSponsor(address payable sponsorAddress) public {
        sponsor = SponsorFunding(sponsorAddress);
        emit SponsorRegistered(sponsorAddress);
    }
    
    function isFundable() public view returns (bool) {
        return totalFunded + getSponsorValue() < fundingGoal;
    }
    
    function getSponsorValue() private view returns (uint) {
        address payable thisAddress = payable(address(this));
        
        if (sponsor.canSponsorContract(thisAddress)) {
            return sponsor.getSponsorshipValue(thisAddress);
        } else {
            return 0;
        }
    }
    
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
    
    function endCrowdFunding() private {
        require(!isFundable(), "CrowdFunding is not yet completed.");
        address payable thisAddress = payable(address(this));
        sponsor.sponsorContract(thisAddress);
        emit CrowdFundingEnded(thisAddress.balance);
        (bool success, bytes memory data) = distributeFundingContract.call{value: thisAddress.balance}("");
        fundable = false;
    }
    
    function returnFunds(address payable contributorAddress, uint sum) public {
        require(contributors[contributorAddress].sum < sum, "This contributor has deposited less than the requested eth.");
        require(totalFunded < fundingGoal, "CrowdFunding has ended.");
        
        totalFunded -= sum;
        contributors[contributorAddress].sum -= sum;
        
        contributorAddress.transfer(sum);
    }
    
    receive() external payable {
        // require(totalFunded < fundingGoal, "Funding already achieved.");
        
        // // uint newTotalFunded = totalFunded + sponsorSum + msg.value;
        // // uint keptValue = msg.value;
        
        // // if (newTotalFunded > fundingGoal) {
        // //     keptValue = msg.value - (newTotalFunded - fundingGoal);
        // //     payable(msg.sender).transfer(msg.value - keptValue);
        // // }
        
        // contributors[msg.sender].sum += msg.value;
        // totalFunded += msg.value;
        
        // if (totalFunded > fundingGoal) {
        //     endCrowdFunding();
        // }
    }
}
