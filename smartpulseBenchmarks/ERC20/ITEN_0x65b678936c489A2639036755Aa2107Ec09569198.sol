pragma solidity ^0.4.23;

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); 
    uint256 c = a / b;

    return c;
  }
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }
  
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

contract owned {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

contract TokenERC20 is owned{
    using SafeMath for uint256;
    string public name = "ITEN";
    string public symbol = "ITEN";
    uint8 public decimals = 18;
    uint256 public totalSupply = 500000000000000000000000000;
    bool public released = true;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Burn(address indexed from, uint256 value);

    
    constructor(
        uint256 initialSupply,
        string memory tokenName,
        string memory tokenSymbol
    ) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);  
        balanceOf[msg.sender] = 0;                
        name = "ITEN";                                  
        symbol = "ITEN";                              
    }

    function release() public onlyOwner{
      require (owner == msg.sender);
      released = !released;
    }

    modifier onlyReleased() {
      require(released);
      _;
    }

    function _transfer(address _from, address _to, uint _value) internal onlyReleased {
        require(_to != address(0x0));
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value > balanceOf[_to]);
        uint previousBalances = balanceOf[_from].add(balanceOf[_to]);
        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        emit Transfer(_from, _to, _value);
        assert(balanceOf[_from].add(balanceOf[_to]) == previousBalances);
    }

    function approve(address _spender, uint256 _value) public onlyReleased
        returns (bool success) {
        require(_spender != address(0));

        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData)
        public onlyReleased
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, address(this), _extraData);
            return true;
        }
    }

    function transfer(address _to, uint256 _value) public onlyReleased returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

 
    function transferFrom(address _from, address _to, uint256 _value) public onlyReleased returns (bool success) {
        require(_value <= allowance[_from][msg.sender]); 
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
        return true;
    }


    function burn(uint256 _value) public onlyReleased returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);           
        totalSupply = totalSupply.sub(_value);                     
        emit Burn(msg.sender, _value);
        return true;
    }
    
    function burnFrom(address _from, uint256 _value) public onlyReleased returns (bool success) {
        require(balanceOf[_from] >= _value);                
        require(_value <= allowance[_from][msg.sender]);    
        balanceOf[_from] = balanceOf[_from].sub(_value);                         
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);             
        totalSupply = totalSupply.sub(_value);                    
        emit Burn(_from, _value);
        return true;
    }
}


contract ITEN is owned, TokenERC20 {

    mapping (address => bool) public frozenAccount;
    event FrozenFunds(address target, bool frozen);
    constructor(
        uint256 initialSupply,
        string memory tokenName,
        string memory tokenSymbol
    ) TokenERC20(initialSupply, tokenName, tokenSymbol) public {
    }

      function _transfer(address _from, address _to, uint _value) internal onlyReleased {
        require (_to != address(0x0));                               
        require (balanceOf[_from] >= _value);               
        require (balanceOf[_to] + _value >= balanceOf[_to]); 
        require(!frozenAccount[_from]);                     
        require(!frozenAccount[_to]);                       
        balanceOf[_from] = balanceOf[_from].sub(_value);       
        balanceOf[_to] = balanceOf[_to].add(_value);   
        emit Transfer(_from, _to, _value);
    }

    
    /// mintedAmount 1 0x18 = 1.000000000000000000
    function mintToken(address target, uint256 mintedAmount) onlyOwner public {
        require (mintedAmount > 0);
        totalSupply = totalSupply.add(mintedAmount);
        balanceOf[target] = balanceOf[target].add(mintedAmount);
        emit Transfer(address(0), address(this), mintedAmount);
        emit Transfer(address(this), target, mintedAmount);
    }

    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }

}
