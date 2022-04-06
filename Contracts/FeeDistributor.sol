// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "./libraries/SafeERC20.sol";
import "./libraries/ERC20.sol";
import "./libraries/SafeMath.sol";
import "./libraries/Ownable.sol";
import "./interfaces/IFeeDistributor.sol";

contract FeeDistributor is IFeeDistributor, Ownable {
    using SafeMath for uint;
    using SafeERC20 for IERC20;

    address public immutable override gremlin;
    address public immutable override xGRM;
    uint public override periodLength;
    uint public override lastClaim;

    constructor(
        address gremlin_,
        address xGRM_,
        uint periodLength_
    ) public {
        gremlin = gremlin_;
        xGRM = xGRM_;
        periodLength = periodLength_;
        lastClaim = block.timestamp;
    }

    function claim() external override returns (uint amount) {
        uint timeElapsed = block.timestamp.sub(lastClaim);
        lastClaim = block.timestamp;
        uint balance = IERC20(gremlin).balanceOf(address(this));
        if (timeElapsed > periodLength) {
            amount = balance;
        } else {
            amount = balance.mul(timeElapsed).div(periodLength);
        }
        if (amount > 0) {
            IERC20(gremlin).safeTransfer(xGRM, amount);
        }
        emit Claim(balance, timeElapsed, amount);
    }

    function setPeriodLength(uint newPeriodLength) external override onlyOwner {
        emit NewPeriodLength(periodLength, newPeriodLength);
        periodLength = newPeriodLength;
    }
}