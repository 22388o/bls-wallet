//SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
pragma abicoder v2;

import "./VerificationGateway.sol";

/**
@dev Optimisations to reduce calldata of VerificationGateway multiCall
with shared params.
*/
contract BLSExpander is Initializable {
    VerificationGateway verificationGateway;
    function initialize(address gateway) public initializer {
        verificationGateway = VerificationGateway(gateway);
    }

    // eg approve and transfers of a token contract
    function blsCallMultiCheckRewardIncrease(
        IERC20 tokenRewardAddress,
        uint256 tokenRewardAmount,
        uint256[4][] calldata publicKeys,
        uint256[2] memory signature,
        VerificationGateway.TxSet[] calldata txs
    ) external returns (uint256 balanceIncrease) {
        uint256 balanceBefore = tokenRewardAddress.balanceOf(tx.origin);

        verificationGateway.actionCalls(
            publicKeys,
            signature,
            txs
        );

        uint256 balanceAfter = tokenRewardAddress.balanceOf(tx.origin);
        balanceIncrease = balanceAfter - balanceBefore;
        require(balanceIncrease >= tokenRewardAmount, "BLSExpander: Insufficient reward");
    }


    // eg approve and transfers of a token contract
    // function blsCallMultiSameContract(
    //     // address rewardAddress,
    //     bytes32[] calldata  publicKeyHashes,
    //     uint256[2] memory signature,
    //     uint256[] calldata tokenRewardAmounts,
    //     address contractAddress,
    //     bytes4[] calldata methodIds,
    //     bytes[] calldata encodedParamSets
    // ) external {
    //     uint256 length = publicKeyHashes.length;
    //     VerificationGateway.TxSet[] memory txs = new VerificationGateway.TxSet[](length);
    //     for (uint256 i=0; i<length; i++) {
    //         txs[i].publicKeyHash = publicKeyHashes[i];
    //         txs[i].tokenRewardAmount = tokenRewardAmounts[i];
    //         txs[i].contractAddress = contractAddress;
    //         txs[i].methodId = methodIds[i];
    //         txs[i].encodedParams = encodedParamSets[i];
    //     }

    //     verificationGateway.blsCallMany(
    //         msg.sender,
    //         signature,
    //         txs
    //     );
    // }

    // eg a set of txs from one account
    // function blsCallMultiSameCaller(
    //     // address rewardAddress,
    //     bytes32 publicKeyHash,
    //     uint256[2] memory signature,
    //     uint256[] calldata tokenRewardAmounts,
    //     address[] calldata contractAddresses,
    //     bytes4[] calldata methodIds,
    //     bytes[] calldata encodedParamSets
    // ) external {
    //     uint256 length = contractAddresses.length;
    //     VerificationGateway.TxSet[] memory txs = new VerificationGateway.TxSet[](length);
    //     for (uint256 i=0; i<length; i++) {
    //         txs[i].publicKeyHash = publicKeyHash;
    //         txs[i].tokenRewardAmount = tokenRewardAmounts[i];
    //         txs[i].contractAddress = contractAddresses[i];
    //         txs[i].methodId = methodIds[i];
    //         txs[i].encodedParams = encodedParamSets[i];
    //     }

    //     verificationGateway.blsCallMany(
    //         msg.sender,
    //         signature,
    //         txs
    //     );
    // }

    // eg airdrop
    function blsCallMultiSameCallerContractFunction(
        uint256[4] calldata publicKey,
        uint256 nonce,
        uint256[2] calldata signature,
        IERC20 ,
        uint256[] calldata ,
        address contractAddress,
        bytes4 methodId,
        bytes[] calldata encodedParamSets
    ) external {
        uint256 length = encodedParamSets.length;

        uint256[4][] memory publicKeys = new uint256[4][](1);
        publicKeys[0] = publicKey;

        VerificationGateway.TxSet[] memory txs = new VerificationGateway.TxSet[](1);
        txs[0].nonce = nonce;
        txs[0].atomic = false;
        txs[0].actions = new IWallet.ActionData[](length);
        for (uint256 i=0; i<length; i++) {
            txs[0].actions[i].ethValue = 0;
            txs[0].actions[i].contractAddress = contractAddress;
            txs[0].actions[i].encodedFunction = abi.encodePacked(methodId, encodedParamSets[i]);
        }

        verificationGateway.actionCalls(
            publicKeys,
            signature,
            txs
        );
    }

    // eg identical txs from multiple accounts
    // function blsCallMultiSameContractFunctionParams(
    //     // address rewardAddress,
    //     bytes32[] calldata  publicKeyHashes,
    //     uint256[2] memory signature,
    //     uint256[] calldata tokenRewardAmounts,
    //     address contractAddress,
    //     bytes4 methodId,
    //     bytes calldata encodedParams
    // ) external {
    //     uint256 length = publicKeyHashes.length;
    //     VerificationGateway.TxSet[] memory txs = new VerificationGateway.TxSet[](length);
    //     for (uint256 i=0; i<length; i++) {
    //         txs[i].publicKeyHash = publicKeyHashes[i];
    //         txs[i].tokenRewardAmount = tokenRewardAmounts[i];
    //         txs[i].contractAddress = contractAddress;
    //         txs[i].methodId = methodId;
    //         txs[i].encodedParams = encodedParams;
    //     }

    //     verificationGateway.blsCallMany(
    //         msg.sender,
    //         signature,
    //         txs
    //     );
    // }

}