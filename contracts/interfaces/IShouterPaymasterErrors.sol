// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IShouterPaymasterErros {
    error OnlyCommitCommentCanBeCalled();
    error InvalidRequestData(bytes data);
    error NotTargetContract();
}
