// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <=0.8.7;

import "./SponsorFunding.sol";

contract CrowdFunding {
    
    // Target ammount of funds to be gathered by this contract.
    uint private fundingGoal;
    
    // Address of the distribute funds contract.
    address payable distributeFundingContract;
    
    // SponsorFunding contract to ask for sponsorship at the end of the crowdfunding.
    SponsorFunding sponsor;
    
    // Mapping of contributor address to it's data. The contributors 
    mapping(address => contributorData) contributors;
     
    /**
     * Contributor information structure. Holds everything needed about wallets that
     * sent funds to this contract.
     */
    struct contributorData {
        uint sum;
        string contributorName;
        address payable contributorAddress;
    }
    
    /// CrowdFunding events. Emmited when funds are received or contract state changes.
    event ContributorFunded(uint sum);
    event SponsorRegistered(address payable);
    event CrowdFundingEnded(uint sentSum);

    constructor(uint _fundingGoal) payable {
        fundingGoal = _fundingGoal;
    }
    
    function getFundingGoal() public view returns (uint) {
        return fundingGoal;
    }
    
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
    
    function getSponsorValue() private view returns (uint) {
        address payable thisAddress = payable(address(this));
        
        if (sponsor.canSponsorContract(thisAddress)) {
            return sponsor.getSponsorshipValue(thisAddress);
        } else {
            return 0;
        }
    }
    
    function isFundable() public view returns (bool) {
        return getBalance() + getSponsorValue() < fundingGoal;
    }
    
    function setFundingGoal(uint _fundingGoal) public {
        fundingGoal = _fundingGoal;
    }
    
    function setDistributeFundingContract(address payable _distributeFundingContract) public {
        distributeFundingContract = _distributeFundingContract;
    }
    
    function setSponsor(address payable sponsorAddress) public {
        sponsor = SponsorFunding(sponsorAddress);
        emit SponsorRegistered(sponsorAddress);
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
        emit ContributorFunded(msg.value);
    }

    function endCrowdFunding() public {
        require(!isFundable(), "CrowdFunding is not yet completed.");
        
        address payable thisAddress = payable(address(this));
        sponsor.sponsorContract(thisAddress);
        
        emit CrowdFundingEnded(thisAddress.balance);
        (bool success, bytes memory data) = distributeFundingContract.call{value: thisAddress.balance}("");
    }
    
    function returnFunds(address payable contributorAddress, uint sum) public {
        require(contributors[contributorAddress].sum < sum, "This contributor has deposited less than the requested eth.");
        require(getBalance() < fundingGoal, "CrowdFunding has ended.");
        
        contributors[contributorAddress].sum -= sum;
        contributorAddress.transfer(sum);
    }
}
