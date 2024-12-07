// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract Crowdfunding{

    string public name;
    string public description;
    uint256 public goal;
    uint256 public deadline;
    address public owner;
    CampaignState public state;

    enum CampaignState {
        Active,
        Successful,
        Failed
    }


    struct Tier {
        string name;
        uint256 amount;
        uint256 backers;
    }


    struct Backer{
        uint256 totalContribution;
        mapping(uint256 => bool) fundedTiers;

    }

    Tier[] public tiers;
    mapping(address => Backer) public backers;

    modifier  onlyOwner(){
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier  campaignOpen(){
        require(state == CampaignState.Active,"Campaign is ended.");
        _;
    }


    constructor(string memory _name, string memory _description, uint256 _goal,
    uint256 _duratyionInDays
    ){
        name = _name;
        description = _description;
        goal = _goal;
        deadline = deadline;
        deadline = block.timestamp + (_duratyionInDays * 1 days);
        owner = msg.sender;
        state = CampaignState.Active;
    }

    function checkAndUpdateCampainState() internal  {
        if(state == CampaignState.Active){
            if(block.timestamp>= deadline){
                state = address(this).balance >= goal ? CampaignState.Successful: CampaignState.Failed;
            }else{
                state = address(this).balance >= goal ? CampaignState.Successful: CampaignState.Active;
            }
        }
    }


    function fund(uint256 _tierIndex) public payable campaignOpen  {
        require(_tierIndex < tiers.length, "Invalid tier.");
        require(msg.value == tiers[_tierIndex].amount, "Incorect amount");

        tiers[_tierIndex].backers++; 

        backers[msg.sender].totalContribution += msg.value;
        backers[msg.sender].fundedTiers[_tierIndex] = true;
        


        checkAndUpdateCampainState();
    }

    function addTier(
        string memory _name,
        uint256 _amount
    ) public onlyOwner {
        require(_amount > 0, "Amount must be greater than 0.");
        tiers.push(Tier(_name, _amount, 0));
    }

    function removeTier(uint256 _index) public onlyOwner {
        require(_index < tiers.length, "Tier doesn't exist.");
        tiers[_index] = tiers[tiers.length  - 1];
        tiers.pop();
    }

    function withdraw() public onlyOwner {
        checkAndUpdateCampainState();
        require(state == CampaignState.Successful, "Campaign not success");
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance to withdraw");

        payable(owner).transfer(balance);
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function refund() public {
        checkAndUpdateCampainState();
        require(state == CampaignState.Failed,"Refunds not available");
        uint256 amount = backers[msg.sender].totalContribution;
        require(amount > 0, "No contribution to refund");
        backers[msg.sender].totalContribution = 0;
        payable(msg.sender).transfer(amount);
    }

    function hasFundedTier(address _backer, uint256 _tierIndex) public view returns (bool){
        return backers[_backer].fundedTiers[_tierIndex];
    }

}
