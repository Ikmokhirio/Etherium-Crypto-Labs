//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";  // OpenZeppelin package contains implementation of the ERC 20 standard, which our NFT smart contract will inherit

enum Option {
    None,
    Rock,
    Paper,
    Scissors
}

contract RockPaperScissors is ERC20 {
    address public player1;
    Option player1Option;

    address public player2;
    Option player2Option;

    uint private bet = 1000000;

    string gameStatus = "Waiting for palyers";

    uint constant _initial_supply = 100 * (10**18);
    constructor() ERC20("RPS_Token", "RPS") {
        _mint(msg.sender, _initial_supply);
    }

    function PlayerWin(Option first, Option second) private pure returns (bool win) {
        if(first == Option.Rock && second == Option.Scissors) {
            return true;
        }
        if(first == Option.Paper && second == Option.Rock) {
            return true;
        }
        if(first == Option.Scissors && second == Option.Paper) {
            return true;
        }
        return false;
    }

    function CheckWinner() public {
        if(player1Option == Option.None && player2Option == Option.None) {
            gameStatus = "Cannot check for winner. Both players haven't selected their inputs";
            return;
        }

        if(player1Option == player2Option) {
            gameStatus = "Draw. Waiting for new players";
        }
        if(PlayerWin(player1Option, player2Option)) {
            emit Transfer(player2, player1, bet);

            gameStatus = "Last game player1 won. Waiting for new players";
        }
        if(PlayerWin(player2Option, player1Option)) {
            _transfer(player1, player2, bet);
            gameStatus = "Last game player2 won. Waiting for new players";
        }
        Restart();
    }

    function SelectOption(uint opt) public  {
        require(msg.sender == player1 || msg.sender == player2, "Not an active player");

        if(msg.sender == player1) {
            gameStatus = "Player1 selected input";
            player1Option = Option(opt);
        }
        if(msg.sender == player2) {
            gameStatus = "Player2 selected input";
            player2Option = Option(opt);
        }

        if(player1Option != Option.None && player2Option != Option.None) {
            gameStatus = "Both players selected input. Check for winner";
        }
    }

    function GetStatus() public view returns (string memory) {
        return gameStatus;
    }

    function Register() public {
        require(player1 == address(0) || player2 == address(0), "Game lobby is full");
        require(balanceOf(msg.sender) >= bet, "You do not have enough money to bet");

        if(player1 == address(0)) {
            gameStatus = "Player1 registered";
            player1 = msg.sender;
        } else if(player2 == address(0)) {
            gameStatus = "Player2 registered";
            player2 = msg.sender;
        }

        if(player1 != address(0) && player2 != address(0)) {
            gameStatus = "Game lobby is full. Awaiting players input";
        }
    }

    function Restart() private {
        player1 = address(0);
        player2 = address(0);
        player1Option = Option.None;
        player2Option = Option.None;
    }
}