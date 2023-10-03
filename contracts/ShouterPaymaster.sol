// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./interfaces/IShouterPaymasterErrors.sol";

import "@opengsn/contracts/src/BasePaymaster.sol";

import "@opengsn/contracts/src/utils/GsnTypes.sol";

contract ShouterPaymaster is BasePaymaster, IShouterPaymasterErros {
    bytes4 targetMethodSig = bytes4(keccak256(bytes("commitComment(string)")));

    constructor() {}

    function versionPaymaster() external pure override returns (string memory) {
        return "v1";
    }

    function _preRelayedCall(
        GsnTypes.RelayRequest calldata relayRequest,
        bytes calldata,
        bytes calldata,
        uint256
    ) internal virtual override returns (bytes memory, bool) {
        IForwarder.ForwardRequest calldata request = relayRequest.request;
        bytes memory data = request.data;
        if (data.length < 4) {
            revert InvalidRequestData(data);
        }
        bytes4 methodSig = bytes4(data[0]) |
            (bytes4(data[1]) << 8) |
            (bytes4(data[2]) << 16) |
            (bytes4(data[3]) << 24);
        if (methodSig != targetMethodSig) {
            revert OnlyCommitCommentCanBeCalled();
        }

        return ("", false);
    }

    function _postRelayedCall(
        bytes calldata,
        bool,
        uint256,
        GsnTypes.RelayData calldata
    ) internal virtual override {}
}
