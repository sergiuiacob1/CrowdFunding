contract SponsorFunding {
    address payable owner;
    
    struct sponsorship {
        uint percentage;
        bool fundsDelivered;
    }
    
    mapping(address => sponsorship) private sponsorshipRegistry;
    
    constructor() payable {
        owner = payable(msg.sender);
    }
    
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
    
    
    function addToSponsorships(address payable receiver, uint _percentage) public {
        sponsorshipRegistry[receiver] = sponsorship({
            percentage: _percentage,
            fundsDelivered: false
        });
    }
    
    function canSponsorContract(address payable receiver) public view returns (bool) {
        CrowdFunding crowdFunding = CrowdFunding(receiver);
        
        if (crowdFunding.isFundable() == false) {
            return false;
        }
        
        if (sponsorshipRegistry[receiver].fundsDelivered == true) {
            return false;
        }
        
        uint sponsorshipValue = sponsorshipRegistry[receiver].percentage * address(receiver).balance / 100;
        
        if (sponsorshipValue + address(receiver).balance < crowdFunding.getFundingGoal()) {
            return false;
        }
        
        if (address(this).balance < sponsorshipValue) {
            return false;
        }
        
        return true;
    }
    
    function getSponsorshipValue(address receiver) view public returns (uint){
        require(sponsorshipRegistry[receiver].fundsDelivered == false, "CrowdFunding contract already funded!");
        
        return sponsorshipRegistry[receiver].percentage * address(receiver).balance / 100;
    }
    
    function sponsorContract(address payable receiver) payable public {
        CrowdFunding crowdFunding = CrowdFunding(receiver);
        
        require(crowdFunding.isFundable(), "CrowdFunding contract not fundable!");
        require(sponsorshipRegistry[receiver].fundsDelivered == false, "CrowdFunding contract already funded!");
        
        uint sponsorshipValue = sponsorshipRegistry[receiver].percentage * address(receiver).balance / 100;
        
        require(sponsorshipValue <= address(this).balance, "Insufficient funds in SponsorFunding cotract!");
        require(sponsorshipValue + address(receiver).balance >= crowdFunding.getFundingGoal(), "CrowdFunding goal is not achievable!");
        
        receiver.transfer(sponsorshipValue);
        sponsorshipRegistry[receiver].fundsDelivered = true;
    }
}