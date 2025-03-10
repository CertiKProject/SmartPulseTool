pragma solidity >=0.5.0;

import './fund/ICrowdsaleFund.sol';
import './math/SafeMath.sol';
import './ownership/MultiOwnable.sol';
import './token/ManagedToken.sol';
import './ISimpleCrowdsale.sol';


contract Fund is ICrowdsaleFund, SafeMath, MultiOwnable {
    enum FundState {
        Crowdsale,
        CrowdsaleRefund,
        TeamWithdraw,
        Refund
    }

    FundState public state = FundState.Crowdsale;
    ManagedToken public token;

    uint256 public constant INITIAL_TAP = 192901234567901; // (wei/sec) == 500 ether/month

    address payable public teamWallet;
    uint256 public crowdsaleEndDate;

    address public referralTokenWallet;
    address public foundationTokenWallet;
    address public reserveTokenWallet;
    address public bountyTokenWallet;
    address public companyTokenWallet;
    address public advisorTokenWallet;
    address public lockedTokenAddress;
    address public refundManager;

    /* uint256 public tap; */
    uint256 public lastWithdrawTime = 0;
    uint256 public firstWithdrawAmount = 0;

    address public crowdsaleAddress;
    mapping(address => uint256) public contributions;

    event RefundContributor(address tokenHolder, uint256 amountWei, uint256 timestamp);
    event RefundHolder(address tokenHolder, uint256 amountWei, uint256 tokenAmount, uint256 timestamp);
    event Withdraw(uint256 amountWei, uint256 timestamp);
    event RefundEnabled(address initiatorAddress);

    /**
     * @dev Fund constructor
     * @param _teamWallet Withdraw functions transfers ether to this address
     * @param _referralTokenWallet Referral wallet address
     * @param _companyTokenWallet Company wallet address
     * @param _reserveTokenWallet Reserve wallet address
     * @param _bountyTokenWallet Bounty wallet address
     * @param _advisorTokenWallet Advisor wallet address
     * @param _owners Contract owners
     */
     constructor(
        address payable _teamWallet,
        address _referralTokenWallet,
        address _foundationTokenWallet,
        address _companyTokenWallet,
        address _reserveTokenWallet,
        address _bountyTokenWallet,
        address _advisorTokenWallet,
        address _refundManager,
        address[] memory _owners
    ) public
    {
        teamWallet = _teamWallet;
        referralTokenWallet = _referralTokenWallet;
        foundationTokenWallet = _foundationTokenWallet;
        companyTokenWallet = _companyTokenWallet;
        reserveTokenWallet = _reserveTokenWallet;
        bountyTokenWallet = _bountyTokenWallet;
        advisorTokenWallet = _advisorTokenWallet;
        refundManager = _refundManager;
        _setOwners(_owners);
    }

    modifier withdrawEnabled() {
        require(canWithdraw());
        _;
    }

    modifier onlyCrowdsale() {
        require(msg.sender == crowdsaleAddress);
        _;
    }

    function canWithdraw() public returns(bool);

    function setCrowdsaleAddress(address _crowdsaleAddress) public onlyOwner {
        require(crowdsaleAddress == address(0));
        crowdsaleAddress = _crowdsaleAddress;
    }

    function setTokenAddress(address _tokenAddress) public onlyOwner {
        require(address(token) == address(0));
        token = ManagedToken(_tokenAddress);
    }

    function setLockedTokenAddress(address _lockedTokenAddress) public onlyOwner {
        require(address(lockedTokenAddress) == address(0));
        lockedTokenAddress = _lockedTokenAddress;
    }

    /**
     * @dev Process crowdsale contribution
     */
    function processContribution(address contributor) external payable onlyCrowdsale {
        require(state == FundState.Crowdsale);
        uint256 totalContribution = safeAdd(contributions[contributor], msg.value);
        contributions[contributor] = totalContribution;
    }

    /**
     * @dev Callback is called after crowdsale finalization if soft cap is reached
     */
    function onCrowdsaleEnd() external onlyCrowdsale {
        state = FundState.TeamWithdraw;
        ISimpleCrowdsale crowdsale = ISimpleCrowdsale(crowdsaleAddress);
	// CHANGE BELOW
        /* firstWithdrawAmount = safeDiv(crowdsale.getSoftCap(), uint256(2)); */
        firstWithdrawAmount = crowdsale.getSoftCap() / 2;
	// CHANGE ABOVE
        lastWithdrawTime = now;
        /* tap = INITIAL_TAP; */
        crowdsaleEndDate = now;
    }

    /**
     * @dev Callback is called after crowdsale finalization if soft cap is not reached
     */
    function enableCrowdsaleRefund() external onlyCrowdsale {
        require(state == FundState.Crowdsale);
        state = FundState.CrowdsaleRefund;
    }

    /**
    * @dev Function is called by contributor to refund payments if crowdsale failed to reach soft cap
    */
    function refundCrowdsaleContributor() external {
        require(state == FundState.CrowdsaleRefund);
        require(contributions[msg.sender] > 0);

        uint256 refundAmount = contributions[msg.sender];
        contributions[msg.sender] = 0;
        token.destroy(msg.sender, token.balanceOf(msg.sender));
        msg.sender.transfer(refundAmount);
        emit RefundContributor(msg.sender, refundAmount, now);
    }

    /**
    * @dev Function is called by owner to refund payments if crowdsale failed to reach soft cap
    */
    function autoRefundCrowdsaleContributor(address payable contributorAddress) external {
        require(ownerByAddress[msg.sender] == true || msg.sender == refundManager);
        require(state == FundState.CrowdsaleRefund);
        require(contributions[contributorAddress] > 0);

        uint256 refundAmount = contributions[contributorAddress];
        contributions[contributorAddress] = 0;
        token.destroy(contributorAddress, token.balanceOf(contributorAddress));
        contributorAddress.transfer(refundAmount);
        emit RefundContributor(contributorAddress, refundAmount, now);
    }

    /* /\** */
    /*  * @dev Decrease tap amount */
    /*  * @param _tap New tap value */
    /*  *\/ */
    /* function decTap(uint256 _tap) external onlyOwner { */
    /*     require(state == FundState.TeamWithdraw); */
    /*     require(_tap < tap); */
    /*     tap = _tap; */
    /* } */

    function getCurrentTapAmount() public view returns(uint256) {
        if(state != FundState.TeamWithdraw) {
            return 0;
        }
        return calcTapAmount();
    }

    function calcTapAmount() internal view returns(uint256) {
	// CHANGED BELOW
	/* uint256 amount = safeMul(safeSub(now, lastWithdrawTime), tap); */      
	uint256 amount = safeSub(now, lastWithdrawTime) * 192901234567901;
	// CHANGED ABOVE	
        if(address(this).balance < amount) {
            amount = address(this).balance;
        }
        return amount;
    }

    function firstWithdraw() public onlyOwner withdrawEnabled {
        require(firstWithdrawAmount > 0);
        uint256 amount = firstWithdrawAmount;
        firstWithdrawAmount = 0;
        teamWallet.transfer(amount);
        emit Withdraw(amount, now);
    }

    /**
     * @dev Withdraw tap amount
     */
    function withdraw() public onlyOwner withdrawEnabled {
        require(state == FundState.TeamWithdraw);
        uint256 amount = calcTapAmount();
        lastWithdrawTime = now;
        teamWallet.transfer(amount);
        emit Withdraw(amount, now);
    }

    // Refund
    /**
     * @dev Called to start refunding
     */
    function enableRefund() internal {
        require(state == FundState.TeamWithdraw);
        state = FundState.Refund;
        token.destroy(lockedTokenAddress, token.balanceOf(lockedTokenAddress));
        token.destroy(companyTokenWallet, token.balanceOf(companyTokenWallet));
        token.destroy(reserveTokenWallet, token.balanceOf(reserveTokenWallet));
        token.destroy(foundationTokenWallet, token.balanceOf(foundationTokenWallet));
        token.destroy(bountyTokenWallet, token.balanceOf(bountyTokenWallet));
        token.destroy(referralTokenWallet, token.balanceOf(referralTokenWallet));
        token.destroy(advisorTokenWallet, token.balanceOf(advisorTokenWallet));
        emit RefundEnabled(msg.sender);
    }

    /**
    * @dev Function is called by contributor to refund
    * Buy user tokens for refundTokenPrice and destroy them
    */
    function refundTokenHolder() public {
        require(state == FundState.Refund);

        uint256 tokenBalance = token.balanceOf(msg.sender);
        require(tokenBalance > 0);
	// CHANGE BELOW
	require(token.totalSupply() == 100);
	require(address(this).balance == 100);	
        /* uint256 refundAmount = safeDiv(safeMul(tokenBalance, address(this).balance), token.totalSupply()); */
	uint256 refundAmount = tokenBalance;
	// CHANGE ABOVE
        require(refundAmount > 0);

        token.destroy(msg.sender, tokenBalance);
        msg.sender.transfer(refundAmount);

        emit RefundHolder(msg.sender, refundAmount, tokenBalance, now);
    }
}

