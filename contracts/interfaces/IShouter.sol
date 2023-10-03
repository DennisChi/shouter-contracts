// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IShouter is IERC721 {
    struct Comment {
        string content;
        address commenter;
    }

    struct Billboard {
        string title;
        string img;
        string desc;
        Comment[] comments;
    }

    event OccupyBillboard(address owner, uint256 tokenId);
    event CommitComment(address commenter, string content);

    error OccupyNotOpen();
    error TooLessMsgValue();
    error AlreadyCommented();
    error TokenNotMinted();

    /**
     * Occupy the billboard if possbile.
     * @dev revert if the balance of this contract is greater than the balance threshold
     * @param billboard the billboard to display
     * @return tokenId the token ID of this billboard
     */
    function occupyBillboard(
        Billboard calldata billboard
    ) external payable returns (uint256 tokenId);

    /**
     * Commit a comment to current billboard
     * @param content commit a comment to the billboard
     */
    function commitComment(string memory content) external;

    /**
     * Get the comments of appointed billboard.
     * @param tokenId the token ID of billboard
     * @return comments queried comments
     */
    function getComments(
        uint256 tokenId
    ) external view returns (Comment[] memory comments);

    /**
     * Get this contract's balance.
     * @return balance the balance of this contract.
     */
    function getBalance() external view returns (uint256 balance);

    /**
     * Get the threshold of balance can occupy.
     * @return threshold the threshold of balance can occupy.
     */
    function getBalanceThreshold() external view returns (uint256 threshold);
}
