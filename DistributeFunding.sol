// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract DistributeFunding {
    struct Beneficiary {
        address payable beneficiaryWallet; // where the beneficiary should receive the money
        uint256 percent; // how much the beneficiary receives from the CrowdFunding
    }

    // Maps each CrowdFunding contract to a list of beneficiaries
    mapping(address => Beneficiary[]) public crowdFundingToBeneficiaries;
    // Memorizes how much of a contract has already been given
    mapping(address => uint256) public crowdFundingPercentGiven;
    // Maps how much money was received from each CrowdFunding
    mapping(address => uint256) public moneyFromCrowdFundings;

    event AddedBeneficiary(Beneficiary beneficiary, address crowdFundingAddress);
    event StartDistribution(address crowdFundingAddress, Beneficiary[] beneficiaries);
    event DistributionDone(address crowdFundingAddress, Beneficiary[] beneficiaries, uint totalSum);
    
    constructor() {}
    
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
    
    // function setCrowdFundingOwner(address crowdFunding) public {
    //     require(msg.sender == crowdFunding, "Only the owner of the CrowdFunding can claim that the contract is his");
    //     crowdFundingOwner[crowdFunding] = msg.sender;
    // }

    // modifier isCrowdFundingOwner(address crowdFunding) {
    //     require(msg.sender == crowdFundingOwner[crowdFunding]);
    //     _;
    // }

    // Only the CrowdFunding owner can add a beneficiary
    function addBeneficiary(address crowdFunding, address payable beneficiaryWalletAddr, uint256 percent) public 
    // isCrowdFundingOwner(crowdFunding) 
    {
        require(
            crowdFundingPercentGiven[crowdFunding] + percent <= 100,
            "The portion for the beneficiary is too high."
        );
        Beneficiary memory newBeneficiary = Beneficiary(payable(beneficiaryWalletAddr), percent);
        crowdFundingToBeneficiaries[crowdFunding].push(newBeneficiary);
        crowdFundingPercentGiven[crowdFunding] += percent;
        emit AddedBeneficiary(newBeneficiary, crowdFunding);
    }
    
    // Receives "money" from a CrowdFunding
    receive() external payable {
        moneyFromCrowdFundings[msg.sender] = msg.value;
    }

    // Distribute the funds of a CrowdFunding to the eligible people
    function distributeFunds(address crowdFunding) public { // isCrowdFundingOwner(crowdFunding)
        require(
            moneyFromCrowdFundings[crowdFunding] > 0,
            "There are no funds for the CrowdFunding to distribute."
        );
        Beneficiary[] memory beneficiaries = crowdFundingToBeneficiaries[crowdFunding];
        uint256 totalSum = moneyFromCrowdFundings[crowdFunding];
        
        emit StartDistribution(crowdFunding, beneficiaries);

        for (uint256 i = 0; i < beneficiaries.length; i++) {
            beneficiaries[i].beneficiaryWallet.transfer(
                totalSum * beneficiaries[i].percent / 100
            );
        }
        
        emit DistributionDone(crowdFunding, beneficiaries, totalSum);
    }
}
