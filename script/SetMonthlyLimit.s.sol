// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/JapanBasicIncomeCoin.sol";

contract SetMonthlyLimitScript is Script {
    function setUp() public {
        // スクリプトの初期設定
    }

    function run() public {
        vm.startBroadcast();

        // 以下にデプロイされたコントラクトのアドレスを指定
        JapanBasicIncomeCoin jbic = JapanBasicIncomeCoin(0xEDb35C6b2784FA502809d4a74Ea00ac07A800eb0);

        // 以下にユーザーアドレスと新しい限度額を指定
        address userAddress = 0x29259AB48215239dBE1bc1e7bFCC818EB426ad7B;
        uint256 newLimit = 100 * 10**18; // 例: 100 JBIC

        //nonce
        // vm.setNonce(userAddress, 6);

        // setMonthlyLimitを実行
        jbic.setMonthlyLimit(userAddress, newLimit);

        vm.stopBroadcast();
    }
}
