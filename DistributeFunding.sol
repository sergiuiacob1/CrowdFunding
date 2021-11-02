// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract DistributeFunding {
    struct Beneficiary {
        address payable beneficiaryWallet; // where the beneficiary should receive the money
        uint256 portion; // how much the beneficiary receives from the CrowdFunding
    }

    // Maps each CrowdFunding contract to a list of beneficiaries
    mapping(address => Beneficiary[]) public fundToBeneficiaries;
    // Maps each beneficiary wallet to the CrowdFundings he's registered into
    // mapping(address payable => address[]) public beneficiaryToCrowdFundings;
    // Maps each CrowdFunding to the owner (the one who created the fund)
    mapping(address => address) public fundOwner;
    // Memorizes how much of a contract has already been given
    mapping(address => uint256) public fundToPortionGiven;
    // Maps how much money was received from each CrowdFunding
    mapping(address => uint256) public moneyFromCrowdFundings;

    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    event StartDistribution(address crowdFundingAddress);
    
    constructor() {}
    
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
    
    function setCrowdFundingOwner(address crowdFunding) public {
        require(msg.sender == crowdFunding, "Only the owner of the CrowdFunding can claim that the contract is his");
        fundOwner[crowdFunding] = msg.sender;
    }

    modifier isCrowdFundingOwner(address crowdFunding) {
        require(msg.sender == fundOwner[crowdFunding]);
        _;
    }

    // Only the CrowdFunding owner can add a beneficiary
    function addBeneficiary(
        address crowdFunding,
        address payable beneficiaryWalletAddr,
        uint256 portion
    ) public 
    // isCrowdFundingOwner(crowdFunding) 
    {
        require(
            fundToPortionGiven[crowdFunding] + portion <= 100,
            "The portion for the beneficiary is too high."
        );
        Beneficiary memory newBeneficiary = Beneficiary(payable(beneficiaryWalletAddr), portion);
        fundToBeneficiaries[crowdFunding].push(newBeneficiary);
        fundToPortionGiven[crowdFunding] += portion;
    }
    
    // Receives "money" from a CrowdFunding
    receive() external payable {
        moneyFromCrowdFundings[msg.sender] = msg.value;
    }

    // Distribute the funds of a CrowdFunding to the eligible people
    function distributeFunds(address crowdFunding)
        public
        //isCrowdFundingOwner(crowdFunding)
    {
        require(
            moneyFromCrowdFundings[crowdFunding] > 0,
            "There are no funds for the CrowdFunding to distribute."
        );
        Beneficiary[] memory beneficiars = fundToBeneficiaries[crowdFunding];

        uint256 totalSum = moneyFromCrowdFundings[crowdFunding];

        for (uint256 i = 0; i < beneficiars.length; i++) {
            beneficiars[i].beneficiaryWallet.transfer(
                totalSum * beneficiars[i].portion / 100
            );
        }
    }
}
