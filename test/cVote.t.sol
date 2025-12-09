// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {cVote} from "../src/cVote.sol";

contract cVoteTest is Test {
    error cVote__NotOwner();
    error cVote__PollDoesNotExist();
    error cVote__PollClosed();
    error cVote__DeadlinePassed();
    error cVote__AlreadyVoted();
    error cVote__InvalidOption();
    error cVote__InvalidOptionsLength();
    error cVote__InvalidDeadline();

    cVote cvote;
    address owner = address(1);
    address voter1 = address(2);
    address voter2 = address(3);
    address nonOwner = address(4);

    function setUp() public {
        vm.prank(owner);
        cvote = new cVote(true); // Only owner can create polls
    }

    function testCreatePollSuccess() public {
        vm.prank(owner);
        string[] memory options = new string[](2);
        options[0] = "Yes";
        options[1] = "No";
        cvote.createPoll("Test Poll", "Description", options, 0);

        cVote.Poll memory poll = cvote.getPoll(0);
        assertEq(poll.title, "Test Poll");
        assertEq(poll.description, "Description");
        assertEq(poll.options.length, 2);
        assertEq(poll.options[0], "Yes");
        assertEq(poll.options[1], "No");
        assertEq(poll.votes.length, 2);
        assertEq(poll.votes[0], 0);
        assertEq(poll.votes[1], 0);
        assertTrue(poll.isOpen);
        assertEq(poll.deadline, 0);
    }

    function testCreatePollRevertNotOwner() public {
        vm.prank(nonOwner);
        string[] memory options = new string[](2);
        options[0] = "Yes";
        options[1] = "No";
        vm.expectRevert(cVote__NotOwner.selector);
        cvote.createPoll("Test Poll", "Description", options, 0);
    }

    function testCreatePollRevertInvalidOptionsLength() public {
        vm.prank(owner);
        string[] memory options = new string[](1);
        options[0] = "Only One";
        vm.expectRevert(cVote__InvalidOptionsLength.selector);
        cvote.createPoll("Test Poll", "Description", options, 0);
    }

    function testCreatePollRevertInvalidDeadline() public {
        vm.prank(owner);
        string[] memory options = new string[](2);
        options[0] = "Yes";
        options[1] = "No";
        vm.expectRevert(cVote__InvalidDeadline.selector);
        cvote.createPoll("Test Poll", "Description", options, block.timestamp);
    }

    function testVoteSuccess() public {
        // Create poll
        vm.prank(owner);
        string[] memory options = new string[](2);
        options[0] = "Yes";
        options[1] = "No";
        cvote.createPoll("Test Poll", "Description", options, 0);

        // Vote
        vm.prank(voter1);
        cvote.vote(0, 0);

        (, uint256[] memory votes) = cvote.getResults(0);
        assertEq(votes[0], 1);
        assertEq(votes[1], 0);
        assertTrue(cvote.hasVoted(0, voter1));
    }

    function testVoteRevertPollDoesNotExist() public {
        vm.prank(voter1);
        vm.expectRevert(cVote__PollDoesNotExist.selector);
        cvote.vote(0, 0);
    }

    function testVoteRevertPollClosed() public {
        // Create poll
        vm.prank(owner);
        string[] memory options = new string[](2);
        options[0] = "Yes";
        options[1] = "No";
        cvote.createPoll("Test Poll", "Description", options, 0);

        // Close poll
        vm.prank(owner);
        cvote.closePoll(0);

        // Try to vote
        vm.prank(voter1);
        vm.expectRevert(cVote__PollClosed.selector);
        cvote.vote(0, 0);
    }

    function testVoteRevertDeadlinePassed() public {
        // Create poll with deadline
        vm.prank(owner);
        string[] memory options = new string[](2);
        options[0] = "Yes";
        options[1] = "No";
        cvote.createPoll("Test Poll", "Description", options, block.timestamp + 100);

        // Warp time past deadline
        vm.warp(block.timestamp + 101);

        // Try to vote
        vm.prank(voter1);
        vm.expectRevert(cVote__DeadlinePassed.selector);
        cvote.vote(0, 0);
    }

    function testVoteRevertAlreadyVoted() public {
        // Create poll
        vm.prank(owner);
        string[] memory options = new string[](2);
        options[0] = "Yes";
        options[1] = "No";
        cvote.createPoll("Test Poll", "Description", options, 0);

        // Vote once
        vm.prank(voter1);
        cvote.vote(0, 0);

        // Try to vote again
        vm.prank(voter1);
        vm.expectRevert(cVote__AlreadyVoted.selector);
        cvote.vote(0, 1);
    }

    function testVoteRevertInvalidOption() public {
        // Create poll
        vm.prank(owner);
        string[] memory options = new string[](2);
        options[0] = "Yes";
        options[1] = "No";
        cvote.createPoll("Test Poll", "Description", options, 0);

        // Try to vote with invalid option index
        vm.prank(voter1);
        vm.expectRevert(cVote__InvalidOption.selector);
        cvote.vote(0, 2);
    }

    function testClosePollSuccess() public {
        // Create poll
        vm.prank(owner);
        string[] memory options = new string[](2);
        options[0] = "Yes";
        options[1] = "No";
        cvote.createPoll("Test Poll", "Description", options, 0);

        // Close poll
        vm.prank(owner);
        cvote.closePoll(0);

        cVote.Poll memory poll = cvote.getPoll(0);
        assertFalse(poll.isOpen);
    }

    function testClosePollRevertNotOwner() public {
        // Create poll
        vm.prank(owner);
        string[] memory options = new string[](2);
        options[0] = "Yes";
        options[1] = "No";
        cvote.createPoll("Test Poll", "Description", options, 0);

        // Try to close as non-owner
        vm.prank(nonOwner);
        vm.expectRevert(cVote__NotOwner.selector);
        cvote.closePoll(0);
    }

    function testClosePollRevertPollDoesNotExist() public {
        vm.prank(owner);
        vm.expectRevert(cVote__PollDoesNotExist.selector);
        cvote.closePoll(0);
    }

    function testGetPoll() public {
        // Create poll
        vm.prank(owner);
        string[] memory options = new string[](2);
        options[0] = "Yes";
        options[1] = "No";
        cvote.createPoll("Test Poll", "Description", options, 0);

        cVote.Poll memory poll = cvote.getPoll(0);
        assertEq(poll.title, "Test Poll");
        assertTrue(poll.isOpen);
    }

    function testGetResults() public {
        // Create poll
        vm.prank(owner);
        string[] memory options = new string[](2);
        options[0] = "Yes";
        options[1] = "No";
        cvote.createPoll("Test Poll", "Description", options, 0);

        // Vote
        vm.prank(voter1);
        cvote.vote(0, 0);

        (string[] memory opts, uint256[] memory votes) = cvote.getResults(0);
        assertEq(opts[0], "Yes");
        assertEq(votes[0], 1);
    }

    function testHasVoted() public {
        // Create poll
        vm.prank(owner);
        string[] memory options = new string[](2);
        options[0] = "Yes";
        options[1] = "No";
        cvote.createPoll("Test Poll", "Description", options, 0);

        // Vote
        vm.prank(voter1);
        cvote.vote(0, 0);

        assertTrue(cvote.hasVoted(0, voter1));
        assertFalse(cvote.hasVoted(0, voter2));
    }
}