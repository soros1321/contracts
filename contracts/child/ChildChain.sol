pragma solidity ^0.4.23;

import "../lib/AttachedSafeMath.sol";
import "../mixin/Ownable.sol";
import "./ChildERC20.sol";


contract ChildChain is Ownable {
  using AttachedSafeMath for uint256;

  //
  // Storage
  //

  // mapping for (root token => child token)
  mapping(address => address) public tokens;

  // deposit mapping
  mapping(uint256 => bool) public deposits;

  //
  // Events
  //
  event NewToken(
    address indexed rootToken,
    address indexed token,
    uint8 _decimals
  );
  event TokenDeposited(
    address indexed rootToken,
    address indexed childToken,
    address indexed user,
    uint256 amount,
    uint256 depositCount
  );

  constructor () public {

  }

  function addToken(
    address _rootToken,
    uint8 _decimals
  ) public onlyOwner returns (address token) {
    // check if root token already exists
    require(tokens[_rootToken] == address(0x0));

    // create new token contract
    token = new ChildERC20(_rootToken, _decimals);

    // add mapping with root token
    tokens[_rootToken] = token;

    // broadcast new token's event
    emit NewToken(_rootToken, token, _decimals);
  }

  function depositTokens(
    address rootToken,
    address user,
    uint256 amount,
    uint256 depositCount
  ) public onlyOwner {
    // check if deposit happens only once
    require(deposits[depositCount] == false);

    // set deposit flag
    deposits[depositCount] = true;

    // retrieve child tokens
    address childToken = tokens[rootToken];

    // check if child token is mapped
    require(childToken != address(0x0));

    // deposit tokens
    ChildERC20 obj = ChildERC20(childToken);
    obj.deposit(user, amount);

    // Emit TokenDeposited event
    emit TokenDeposited(rootToken, childToken, user, amount, depositCount);
  }
}
