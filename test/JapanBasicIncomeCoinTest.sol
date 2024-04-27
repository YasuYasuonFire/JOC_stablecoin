// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/JapanBasicIncomeCoin.sol";

contract JapanBasicIncomeCoinTest is Test {
    JapanBasicIncomeCoin jbic;
    address owner;
    address user;

    function setUp() public {
        owner = address(this); // テストコントラクトが所有者になります
        user = address(0x1); // ダミーのユーザーアドレス

        jbic = new JapanBasicIncomeCoin(owner);
        // jbic.mint(owner, 1000 * 10**18); // 初期トークンを発行
    }

    function testSetMonthlyLimit() public {
        uint256 limitAmount = 500 * 10**18;
        jbic.setMonthlyLimit(user, limitAmount);
        uint256 actualLimit = jbic.getMonthlyLimit(user);
        assertEq(actualLimit, limitAmount, "Monthly limit should be correctly set");
    }

    function testTransferWithinLimit() public {
        jbic.setMonthlyLimit(owner, 200 * 10**18);
        bool result = jbic.transfer(user, 100 * 10**18);
        assertTrue(result, "Transfer should succeed within the limit");
    }

    function testTransferExceedsLimit() public {
        jbic.setMonthlyLimit(owner, 50 * 10**18);
        vm.expectRevert("Transfer amount exceeds monthly limit");
        jbic.transfer(user, 100 * 10**18);
    }

}
