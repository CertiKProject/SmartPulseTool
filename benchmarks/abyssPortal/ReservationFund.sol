pragma solidity >=0.5.0;

import './fund/ICrowdsaleReservationFund.sol';
import './ISimpleCrowdsale.sol';
import './ownership/Ownable.sol';
import './math/SafeMath.sol';


contract ReservationFund is ICrowdsaleReservationFund, Ownable, SafeMath {
    bool public crowdsaleFinished = false;

    mapping(address => uint256) contributions;
    mapping(address => uint256) tokensToIssue;
    mapping(address => uint256) bonusTokensToIssue;

    ISimpleCrowdsale public crowdsale;

    event RefundPayment(address contributor, uint256 etherAmount);
    event TransferToFund(address contributor, uint256 etherAmount);
    event FinishCrowdsale();

    constructor(address _owner) public Ownable(_owner) {
    }

    modifier onlyCrowdsale() {
        require(msg.sender == address(crowdsale));
        _;
    }

    function setCrowdsaleAddress(address crowdsaleAddress) public onlyOwner {
        require(address(crowdsale) == address(0));
        crowdsale = ISimpleCrowdsale(crowdsaleAddress);
    }

    function onCrowdsaleEnd() external onlyCrowdsale {
        crowdsaleFinished = true;
        emit FinishCrowdsale();
    }


    function canCompleteContribution(address contributor) external returns(bool) {
        if(crowdsaleFinished) {
            return false;
        }
        if(!crowdsale.isContributorInLists(contributor)) {
            return false;
        }
        if(contributions[contributor] == 0) {
            return false;
        }
        return true;
    }

    /**
     * @dev Function to check contributions by address
     */
    function contributionsOf(address contributor) external returns(uint256) {
        return contributions[contributor];
    }

    /**
     * @dev Process crowdsale contribution without whitelist
     */
    function processContribution(
        address contributor,
        uint256 _tokensToIssue,
        uint256 _bonusTokensToIssue
    ) external payable onlyCrowdsale {
        contributions[contributor] = safeAdd(contributions[contributor], msg.value);
        tokensToIssue[contributor] = safeAdd(tokensToIssue[contributor], _tokensToIssue);
        bonusTokensToIssue[contributor] = safeAdd(bonusTokensToIssue[contributor], _bonusTokensToIssue);
    }

    /**
     * @dev Complete contribution after if user is whitelisted
     */
    function completeContribution(address contributor) external {
        require(!crowdsaleFinished);
        require(crowdsale.isContributorInLists(contributor));
        require(contributions[contributor] > 0);

        uint256 etherAmount = contributions[contributor];
        uint256 tokenAmount = tokensToIssue[contributor];
        uint256 tokenBonusAmount = bonusTokensToIssue[contributor];

        contributions[contributor] = 0;
        tokensToIssue[contributor] = 0;
        bonusTokensToIssue[contributor] = 0;

        crowdsale.processReservationFundContribution.value(etherAmount)(contributor, tokenAmount, tokenBonusAmount);
        emit TransferToFund(contributor, etherAmount);
    }

    /**
     * @dev Refund payments if crowdsale is finalized
     */
    function refundPayment(address payable contributor) public {
        require(crowdsaleFinished);
        require(contributions[contributor] > 0 || tokensToIssue[contributor] > 0);
        uint256 amountToRefund = contributions[contributor];

        contributions[contributor] = 0;
        tokensToIssue[contributor] = 0;
        bonusTokensToIssue[contributor] = 0;

        contributor.transfer(amountToRefund);
        emit RefundPayment(contributor, amountToRefund);
    }
}

