// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract SponsorshipFunding{}
contract CrowdFunding{}


contract DistributeFunding {
    struct Beneficiary {
        address payable beneficiaryWallet; // where the beneficiary should receive the money
        uint portion; // how much the beneficiary receives from the CrowdFunding
    }
    
    // Maps each CrowdFunding contract to a list of beneficiaries
    mapping(address => Beneficiary[]) public fundToBeneficiaries;
    // Maps each beneficiary wallet to the CrowdFundings he's registered into
    // mapping(address payable => address[]) public beneficiaryToCrowdFundings;
    // Maps each CrowdFunding to the owner (the one who created the fund)
    mapping(address => address) public fundOwner;
    // Memorizes how much of a contract has already been given
    mapping(address => uint) public fundToPortionGiven;
    // Maps how much money was received from each CrowdFunding
    mapping(address => uint) public moneyFromCrowdFundings;
    
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    event StartDistribution(address crowdFundingAddress, SponsorshipFunding sponsor);
    
    modifier isCrowdFundingOwner(address crowdFunding) {
        require (msg.sender == fundOwner[crowdFunding]);
        _;
    }
    
    // Only the CrowdFunding owner can add a beneficiary
    function addBeneficiary 
    (address crowdFunding,
    address payable beneficiaryWalletAddr, 
    uint portion) 
    public isCrowdFundingOwner(crowdFunding) {
    // TODO Don't add a Beneficiary that already exists for this CrowdFunding
    require (fundToPortionGiven[crowdFunding] + portion <= 100, "The portion for the beneficiary is too high.");
        fundToBeneficiaries[crowdFunding].push(Beneficiary(beneficiaryWalletAddr, portion));
    }
    
    // Receives "money" from a CrowdFunding
    receive() external payable {
        moneyFromCrowdFundings[msg.sender] = msg.value;
    }

    // Distribute the funds of a CrowdFunding to the eligible people
    function distributeFunds(address crowdFunding) public isCrowdFundingOwner(crowdFunding) {
        require(moneyFromCrowdFundings[crowdFunding] > 0, "There are no funds for the CrowdFunding to distribute.");
        Beneficiary[] memory beneficiars = fundToBeneficiaries[crowdFunding];
        
        uint totalSum = crowdFunding.balance;
        
        for (uint i = 0; i < beneficiars.length; i++){
            beneficiars[i].beneficiaryWallet.transfer(totalSum * beneficiars[i].portion);
        }
    }

}