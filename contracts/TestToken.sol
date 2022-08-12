// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./OwnableExt.sol";

contract TestToken is ERC20, OwnableExt {
    constructor() ERC20("Test Token", "TT") {}

    function mint(uint256 _amount) external onlyOwner {
        _mint(msg.sender, _amount);
    }
}
