// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./interfaces/IShouter.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Shouter is ERC721, IShouter {
    using Counters for Counters.Counter;

    uint256 balanceThreshold;
    Counters.Counter tokenIdCounter;
    address payable balanceCollector;

    /**
     * @dev `tokenId` => `billboard`
     */
    mapping(uint256 => Billboard) billboardOf;

    /**
     * @dev `caller` => `lastCommentBillboard`
     */
    mapping(address => uint256) lastCommentBillboardOf;

    constructor(
        uint256 threshold,
        address collector
    ) ERC721("Shouter", "Shouter") {
        balanceThreshold = threshold;
        balanceCollector = payable(collector);
    }

    function occupyBillboard(
        Billboard calldata billboard
    ) external payable override returns (uint256 tokenId) {
        uint256 balance = address(this).balance;
        if (balance > balanceThreshold) {
            revert OccupyNotOpen();
        }
        if (msg.value <= balanceThreshold) {
            revert TooLessMsgValue();
        }

        tokenIdCounter.increment();
        tokenId = tokenIdCounter.current();
        billboardOf[tokenId] = billboard;
        balanceCollector.transfer(balance);
        payable(address(this)).transfer(msg.value);

        emit OccupyBillboard(msg.sender, tokenId);
    }

    function commitComment(string memory content) external override {
        uint256 tokenId = tokenIdCounter.current();
        uint256 lastCommentBillboard = lastCommentBillboardOf[msg.sender];
        if (lastCommentBillboard == tokenId) {
            revert AlreadyCommented();
        }
        // TODO: GSN or Paymaster
        Billboard storage billboard = billboardOf[tokenId];
        Comment memory comment = Comment({
            commenter: msg.sender,
            content: content
        });
        billboard.comments.push(comment);

        emit CommitComment(msg.sender, content);
    }

    function getComments(
        uint256 tokenId
    ) external view override returns (Comment[] memory comments) {
        Billboard memory billboard = billboardOf[tokenId];
        comments = billboard.comments;
    }

    function getBalance() external view override returns (uint256 balance) {
        return address(this).balance;
    }

    function getBalanceThreshold()
        external
        view
        override
        returns (uint256 threshold)
    {
        return balanceThreshold;
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        if (!_exists(tokenId)) {
            revert TokenNotMinted();
        }
        Billboard memory billboard = billboardOf[tokenId];
        string memory res = '{"title":"';
        res = string.concat(res, billboard.title);
        res = string.concat(res, '","desc":"');
        res = string.concat(res, billboard.desc);
        res = string.concat(res, '","image":"');
        res = string.concat(res, billboard.desc);
        res = string.concat(res, '","comments":[');
        Comment[] memory comments = billboard.comments;
        for (uint256 i = 0; i < comments.length; i++) {
            Comment memory comment = comments[i];
            res = string.concat(res, '{"commenter":"');
            string memory commenter = toString(comment.commenter);
            res = string.concat(res, commenter);
            res = string.concat(res, '","content":"');
            res = string.concat(res, comment.content);
            res = string.concat(res, '"}');
            if (i != comments.length - 1) {
                res = string.concat(res, ",");
            }
        }
        res = string.concat(res, "]}");
        return res;
    }

    function toString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint256 i = 0; i < 20; i++) {
            bytes1 b = bytes1(
                uint8(uint256(uint160(x)) / (2 ** (8 * (19 - i))))
            );
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2 * i] = char(hi);
            s[2 * i + 1] = char(lo);
        }
        return string(s);
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }
}
