// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/*
NaughtCoin — это токен ERC20, и вы уже держите их все. 
Загвоздка в том, что вы сможете передать их только после 10-летнего периода блокировки.
Можете ли вы придумать, как вывести их на другой адрес, чтобы можно было свободно передавать? 
Завершите этот уровень, доведя баланс ваших токенов до 0.

Вам в помощь:
1. спецификация ERC20
2. кодовая база OpenZeppelin
*/

contract Coin is ERC20 {
    // string public constant name = 'Coin';
    // string public constant symbol = '0x0';
    // uint public constant decimals = 18;
    uint public timeLock = block.timestamp + 10 * 365 days;
    uint256 public INITIAL_SUPPLY;
    address public player;

    constructor() ERC20("Coin", "0x0") {
        player = msg.sender;
        INITIAL_SUPPLY = 1000000 * (10 ** uint256(decimals()));
        // _totalSupply = INITIAL_SUPPLY;
        // _balances[player] = INITIAL_SUPPLY;
        _mint(player, INITIAL_SUPPLY);
    }

    function transfer(
        address _to,
        uint256 _value
    ) public override lockTokens returns (bool) {
        super.transfer(_to, _value);
    }

    // Не позволяйте первоначальному владельцу передавать токены до тех пор, пока не пройдет временная блокировка
    modifier lockTokens() {
        if (msg.sender == player) {
            require(block.timestamp > timeLock);
            _;
        } else {
            _;
        }
    }
}

/* -------------------- Hack -------------------- */
/* 
    Description.

    Just use approve and transferFrom instead of direct transfer calling.
    transferFrom does not use transfer function, since modifier lockTokens not going to be applied.
    It can be done without creating attacker contract.
*/
