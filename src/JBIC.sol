// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract JapanBasicIncomeCoin is ERC20, Ownable {
    mapping(address => uint256) private _monthlyLimits;//ユーザーごとの月毎限度額を保持
    mapping(address => uint256) private _monthlySpent;//ユーザーごとの月毎使用数量を保持
    mapping(address => uint256) private _lastResetTimestamp;//最後に月毎使用数量をリセットしたタイムスタンプを保持

    uint256 public constant RESET_INTERVAL = 30 days;

    event MonthlyLimitUpdated(address indexed user, uint256 newLimit);
    event MonthlyLimitReset(address indexed user);

    constructor() ERC20("JapanBasicIncomeCoin", "JBIC") {}

    function setMonthlyLimit(address user, uint256 amount) public onlyOwner {
        require(user != address(0), "Invalid address");
        _monthlyLimits[user] = amount;
        emit MonthlyLimitUpdated(user, amount);
    }

    function getMonthlyLimit(address user) public view returns (uint256) {
        return _monthlyLimits[user];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(_checkLimit(msg.sender, amount), "Transfer amount exceeds monthly limit");
        _monthlySpent[msg.sender] += amount;
        return super.transfer(recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(_checkLimit(sender, amount), "Transfer amount exceeds monthly limit");
        _monthlySpent[sender] += amount;
        return super.transferFrom(sender, recipient, amount);
    }

    function _checkLimit(address user, uint256 amount) private returns (bool) {
        _resetIfNecessary(user);
        uint256 remainingLimit = _monthlyLimits[user] - _monthlySpent[user];
        return amount <= remainingLimit; //使用可能の残り数量をamountが下回るときに、trueを返す。
    }

    //ユーザーがtranferを行おうとしたタイミングで、前回の残り数量リセットよりINTERVAL経過していれば、リセットする。
    function _resetIfNecessary(address user) private {
        if (block.timestamp >= _lastResetTimestamp[user] + RESET_INTERVAL) {
            _monthlySpent[user] = 0;
            _lastResetTimestamp[user] = block.timestamp;
            emit MonthlyLimitReset(user);
        }
    }

}
