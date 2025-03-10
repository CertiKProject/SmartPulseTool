pragma solidity ^0.5.0;




/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}









/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances. 
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of. 
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}




/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    uint256 _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifing the amount of tokens still avaible for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}



/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will recieve the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) public onlyOwner canMint returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() public onlyOwner returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}

/**
 * @title Crowdsale 
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end block, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet 
 * as they arrive.
 */
contract Crowdsale {
  using SafeMath for uint256;

  // The token being sold
  MintableToken public token;

  // start and end block where investments are allowed (both inclusive)
  uint256 public startBlock;
  uint256 public endBlock;

  // address where funds are collected
  address payable public wallet;

  // how many token units a buyer gets per wei
  uint256 public rate;

  // amount of raised money in wei
  uint256 public weiRaised;

  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */ 
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


  constructor(uint256 _startBlock, uint256 _endBlock, uint256 _rate, address payable _wallet) public {
    require(_startBlock >= now);
    require(_endBlock >= _startBlock);
    require(_rate > 0);
    require(_wallet != address(0x0));

    token = createTokenContract();
    startBlock = _startBlock;
    endBlock = _endBlock;
    rate = _rate;
    wallet = _wallet;
  }

  // creates the token to be sold. 
  // override this method to have crowdsale of a specific mintable token.
  function createTokenContract() internal returns (MintableToken) {
    return new MintableToken();
  }


  // fallback function can be used to buy tokens
  function () external payable {
    buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != address(0x0));
    require(validPurchase());

    uint256 weiAmount = msg.value;

    // calculate token amount to be created
    uint256 tokens = weiAmount.mul(rate);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    token.mint(beneficiary, tokens);
    emit TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }

  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

  // @return true if the transaction can buy tokens
  function validPurchase() internal view returns (bool) {
    uint256 current = now;
    bool withinPeriod = current >= startBlock && current <= endBlock;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

  // @return true if crowdsale event has ended
  function hasEnded() public view returns (bool) {
    return now > endBlock;
  }

}

/**
 * @title CappedCrowdsale
 * @dev Extension of Crowsdale with a max amount of funds raised
 */
contract CappedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 public cap;

  constructor(uint256 _cap) public {
    require(_cap > 0);
    cap = _cap;
  }

  // overriding Crowdsale#validPurchase to add extra cap logic
  // @return true if investors can buy at the moment
  function validPurchase() internal view returns (bool) {
    bool withinCap = weiRaised.add(msg.value) <= cap;
    return super.validPurchase() && withinCap;
  }

  // overriding Crowdsale#hasEnded to add cap logic
  // @return true if crowdsale event has ended
  function hasEnded() public view returns (bool) {
    bool capReached = weiRaised >= cap;
    return super.hasEnded() || capReached;
  }

}


/**
 * @title FinalizableCrowdsale
 * @dev Extension of Crowsdale where an owner can do extra work
 * after finishing. By default, it will end token minting.
 */
contract FinalizableCrowdsale is Crowdsale, Ownable {
  using SafeMath for uint256;

  bool public isFinalized = false;

  event Finalized();

  // should be called after crowdsale ends, to do
  // some extra finalization work
  function finalize() public onlyOwner {
    require(!isFinalized);
    require(hasEnded());

    finalization();
    emit Finalized();
    
    isFinalized = true;
  }

  // end token minting on finalization
  // override this with custom logic if needed
  function finalization() internal {
    token.finishMinting();
  }



}


/**
 * @title WhitelistedCrowdsale
 * @dev Extension of Crowsdale where an owner can whitelist addresses
 * which can buy in crowdsale before it opens to the public 
 */
contract WhitelistedCrowdsale is Crowdsale, Ownable {
    using SafeMath for uint256;

    // list of addresses that can purchase before crowdsale opens
    mapping (address => bool) public whitelist;

    function addToWhitelist(address buyer) public onlyOwner {
        require(buyer != address(0x0));
        whitelist[buyer] = true; 
    }

    // @return true if buyer is whitelisted
    function isWhitelisted(address buyer) public view returns (bool) {
        return whitelist[buyer];
    }

    // overriding Crowdsale#validPurchase to add whitelist logic
    // @return true if buyers can buy at the moment
    function validPurchase() internal view returns (bool) {
        // [TODO] issue with overriding and associativity of logical operators
        return super.validPurchase() || (!hasEnded() && isWhitelisted(msg.sender)); 
    }

}



/**
 * @title ContinuousSale
 * @dev ContinuousSale implements a contract for managing a continuous token sale
 */
contract ContinuousSale {
    using SafeMath for uint256;

    // time bucket size
    uint256 public constant BUCKET_SIZE = 12 hours;

    // the token being sold
    MintableToken public token;

    // address where funds are collected
    address payable public wallet;

    // amount of tokens emitted per wei
    uint256 public rate;

    // amount of raised money in wei
    uint256 public weiRaised;

    // max amount of tokens to mint per time bucket
    uint256 public issuance;

    // last time bucket from which tokens have been purchased
    uint256 public lastBucket = 0;

    // amount issued in the last bucket
    uint256 public bucketAmount = 0;

    event TokenPurchase(address indexed investor, address indexed beneficiary, uint256 weiAmount, uint256 tokens);

    constructor(
        uint256 _rate,
        address payable _wallet,
        MintableToken _token
    ) public {
        require(_rate != 0);
        require(_wallet != address(0));
        // require(address(token) != 0x0);

        rate = _rate;
        wallet = _wallet;
        token = _token;
    }

    function() external payable {
        buyTokens(msg.sender);
    }

    function buyTokens(address beneficiary) public payable {
        require(beneficiary != address(0x0));
        require(msg.value != 0);

        prepareContinuousPurchase();
        uint256 tokens = processPurchase(beneficiary);
        checkContinuousPurchase(tokens);
    }

    function prepareContinuousPurchase() internal {
        uint256 timestamp = now;
        //uint256 bucket = timestamp - (timestamp % BUCKET_SIZE);
        uint256 amt = timestamp / 43200;
        uint256 bucket = timestamp - amt * 43200;

        if (bucket > lastBucket) {
            lastBucket = bucket;
            bucketAmount = 0;
        }
    }

    function checkContinuousPurchase(uint256 tokens) internal {
        uint256 updatedBucketAmount = bucketAmount.add(tokens);
        require(updatedBucketAmount <= issuance);

        bucketAmount = updatedBucketAmount;
    }

    function processPurchase(address beneficiary) internal returns(uint256) {
        uint256 weiAmount = msg.value;

        // calculate token amount to be created
        uint256 tokens = weiAmount.mul(rate);

        // update state
        weiRaised = weiRaised.add(weiAmount);

        token.mint(beneficiary, tokens);
        emit TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

        forwardFunds();

        return tokens;
    }

    function forwardFunds() internal {
        wallet.transfer(msg.value);
    }
}






/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev modifier to allow actions only when the contract IS paused
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev modifier to allow actions only when the contract IS NOT paused
   */
  modifier whenPaused {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyOwner whenNotPaused returns (bool) {
    paused = true;
    emit Pause();
    return true;
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyOwner whenPaused returns (bool) {
    paused = false;
    emit Unpause();
    return true;
  }
}

/**
 * Pausable token
 *
 * Simple ERC20 Token example, with pausable token creation
 **/

contract PausableToken is StandardToken, Pausable {

  function transfer(address _to, uint _value) public whenNotPaused returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint _value) public whenNotPaused returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }
}


/**
 * @title Burnable Token
 * @dev A token that can be irreversibly burned.
 */
contract BurnableToken is StandardToken {

    event Burn(address indexed burner, uint256 value);

    /**
     * @dev Burns a specified amount of tokens.
     * @param _value The amount of tokens to burn. 
     */
    function burn(uint256 _value) public {
        require(_value > 0);

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(msg.sender, _value);
    }
}

contract MANAToken is BurnableToken, PausableToken, MintableToken {

    string public constant symbol = "MANA";

    string public constant name = "Decentraland MANA";

    uint8 public constant decimals = 18;

    function burn(uint256 _value) whenNotPaused public {
        super.burn(_value);
    }
}

contract MANAContinuousSale is ContinuousSale, Ownable {

    uint256 public constant INFLATION = 8;

    bool public started = false;

    event RateChange(uint256 amount);

    event WalletChange(address wallet);

    constructor(
        uint256 _rate,
        address payable _wallet,
        MintableToken _token
    ) ContinuousSale(_rate, _wallet, _token) public {
    }

    modifier whenStarted() {
        require(started);
        _;
    }

    function start() public onlyOwner {
        require(!started);

        // initialize issuance
        uint256 finalSupply = token.totalSupply();
        //uint256 annualIssuance = finalSupply.mul(INFLATION).div(100);
        uint256 annualIssuance = finalSupply * 8 / 100;
        //issuance = annualIssuance.mul(BUCKET_SIZE).div(365 days);
        issuance = annualIssuance * 12 / 8760;

        started = true;
    }

    function buyTokens(address beneficiary) whenStarted public payable {
        super.buyTokens(beneficiary);
    }

    function setWallet(address payable _wallet) public onlyOwner {
        require(_wallet != address(0x0));
        wallet = _wallet;
        emit WalletChange(_wallet);
    }

    function setRate(uint256 _rate) public onlyOwner {
        rate = _rate;
        emit RateChange(_rate);
    }

    function unpauseToken() public onlyOwner {
        MANAToken(address(token)).unpause();
    }

    function pauseToken() public onlyOwner {
        MANAToken(address(token)).pause();
    }
}

contract MANACrowdsale is WhitelistedCrowdsale, CappedCrowdsale, FinalizableCrowdsale {

    uint256 public constant TOTAL_SHARE = 100;
    uint256 public constant CROWDSALE_SHARE = 40;
    uint256 public constant FOUNDATION_SHARE = 60;

    // price at which whitelisted buyers will be able to buy tokens
    uint256 public preferentialRate;

    // customize the rate for each whitelisted buyer
    mapping (address => uint256) public buyerRate;

    // initial rate at which tokens are offered
    uint256 public initialRate;

    // end rate at which tokens are offered
    uint256 public endRate;

    // continuous crowdsale contract
    MANAContinuousSale public continuousSale;

    event WalletChange(address wallet);

    event PreferentialRateChange(address indexed buyer, uint256 rate);

    event InitialRateChange(uint256 rate);

    event EndRateChange(uint256 rate);

    constructor(
        uint256 _startBlock,
        uint256 _endBlock,
        uint256 _initialRate,
        uint256 _endRate,
        uint256 _preferentialRate,
        address payable _wallet
    )   public 
        CappedCrowdsale(86206 ether)
        WhitelistedCrowdsale()
        FinalizableCrowdsale()
        Crowdsale(_startBlock, _endBlock, _initialRate, _wallet)
    {
        require(_initialRate > 0);
        require(_endRate > 0);
        require(_preferentialRate > 0);

        initialRate = _initialRate;
        endRate = _endRate;
        preferentialRate = _preferentialRate;

        continuousSale = createContinuousSaleContract();

        MANAToken(address(token)).pause();
    }

    function createTokenContract() internal returns(MintableToken) {
        return new MANAToken();
    }

    function createContinuousSaleContract() internal returns(MANAContinuousSale) {
        return new MANAContinuousSale(rate, wallet, token);
    }

    function setBuyerRate(address buyer, uint256 rate) onlyOwner public {
        require(rate != 0);
        require(isWhitelisted(buyer));
        require(now < startBlock);

        buyerRate[buyer] = rate;

        emit PreferentialRateChange(buyer, rate);
    }

    function setInitialRate(uint256 rate) onlyOwner public {
        require(rate != 0);
        require(now < startBlock);

        initialRate = rate;

        emit InitialRateChange(rate);
    }

    function setEndRate(uint256 rate) onlyOwner public {
        require(rate != 0);
        require(now < startBlock);

        endRate = rate;

        emit EndRateChange(rate);
    }

    function getRate() internal returns(uint256) {
        // some early buyers are offered a discount on the crowdsale price
        if (buyerRate[msg.sender] != 0) {
            return buyerRate[msg.sender];
        }

        // whitelisted buyers can purchase at preferential price before crowdsale ends
        if (isWhitelisted(msg.sender)) {
            return preferentialRate;
        }

        // otherwise compute the price for the auction
        uint256 elapsed = now - startBlock;
        uint256 rateRange = initialRate - endRate;
        uint256 blockRange = endBlock - startBlock;

        return initialRate.sub(rateRange.mul(elapsed).div(blockRange));
    }

    // low level token purchase function
    function buyTokens(address beneficiary) public payable {
        require(beneficiary != address(0x0));
        require(validPurchase());

        uint256 weiAmount = msg.value;
        uint256 updatedWeiRaised = weiRaised.add(weiAmount);

        uint256 rate = getRate();
        // calculate token amount to be created
        uint256 tokens = weiAmount.mul(rate);

        // update state
        weiRaised = updatedWeiRaised;

        token.mint(beneficiary, tokens);
        emit TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

        forwardFunds();
    }

    function setWallet(address payable _wallet) onlyOwner public {
        require(_wallet != address(0x0));
        wallet = _wallet;
        continuousSale.setWallet(_wallet);
        emit WalletChange(_wallet);
    }

    function unpauseToken() public onlyOwner {
        require(isFinalized);
        MANAToken(address(token)).unpause();
    }

    function pauseToken() public onlyOwner {
        require(isFinalized);
        MANAToken(address(token)).pause();
    }


    function beginContinuousSale() onlyOwner public {
        require(isFinalized);

        token.transferOwnership(address(continuousSale));

        continuousSale.start();
        continuousSale.transferOwnership(owner);
    }

    function finalization() internal {
        uint256 totalSupply = token.totalSupply();
        //uint256 finalSupply = TOTAL_SHARE.mul(totalSupply).div(CROWDSALE_SHARE);
        uint256 finalSupply = totalSupply * 100 / 40;

        // emit tokens for the foundation
        //token.mint(wallet, FOUNDATION_SHARE.mul(finalSupply).div(TOTAL_SHARE));
        token.mint(wallet, finalSupply * 60 / 100);

        // NOTE: cannot call super here because it would finish minting and
        // the continuous sale would not be able to proceed
    }

}

/*contract Deployer {
    constructor() public {
        MANACrowdsale m = new MANACrowdsale(100, 1000, 1000, 900, 2000, address(0xABC11111111111111111111111111111111));
    }
}*/
