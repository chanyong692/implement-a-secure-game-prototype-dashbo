// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/access/Roles.sol";
import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/utils/Counters.sol";

contract SecureGamePrototypeDashboard {
    using Roles for address;
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    // Define game roles
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant PLAYER_ROLE = keccak256("PLAYER_ROLE");

    // Game dashboard state
    mapping(address => uint256) public playerScore;
    mapping(address => uint256) public playerLevel;
    mapping(address => bool) public playerBanned;

    Counters.Counter public gameRound;

    // Event emitted when a new game round starts
    event NewRound(uint256 roundNumber);

    // Event emitted when a player's score is updated
    event ScoreUpdated(address player, uint256 newScore);

    // Event emitted when a player is banned
    event PlayerBanned(address player);

    // Event emitted when a player is unbanned
    event PlayerUnbanned(address player);

    // Modifier to check if the caller has the ADMIN_ROLE
    modifier onlyAdmin() {
        require(msg.sender.hasRole(ADMIN_ROLE), "Only admin can call this function");
        _;
    }

    // Modifier to check if the caller has the PLAYER_ROLE
    modifier onlyPlayer() {
        require(msg.sender.hasRole(PLAYER_ROLE), "Only player can call this function");
        _;
    }

    // Function to start a new game round
    function startNewRound() public onlyAdmin {
        gameRound.increment();
        emit NewRound(gameRound.current());
    }

    // Function to update a player's score
    function updateScore(address player, uint256 newScore) public onlyAdmin {
        require(!playerBanned[player], "Player is banned");
        playerScore[player] = newScore;
        emit ScoreUpdated(player, newScore);
    }

    // Function to ban a player
    function banPlayer(address player) public onlyAdmin {
        require(!playerBanned[player], "Player is already banned");
        playerBanned[player] = true;
        emit PlayerBanned(player);
    }

    // Function to unban a player
    function unbanPlayer(address player) public onlyAdmin {
        require(playerBanned[player], "Player is not banned");
        playerBanned[player] = false;
        emit PlayerUnbanned(player);
    }

    // Function to level up a player
    function levelUpPlayer(address player) public onlyAdmin {
        require(!playerBanned[player], "Player is banned");
        playerLevel[player] = playerLevel[player].add(1);
    }
}