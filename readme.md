# Author: Stepan Popov

## Navigation

Each `.sol` file in [contracts](./contracts) directory contains description of exploit and sources of attacker contracts if presented.
Tests located in [test](./test) directory.

## Intallation

1. Install Node.js. Tested on version `v21.5.0`.
2. Install `yarn`.

```bash
npm install --global yarn
```

3. Install dependancies.

```bash
yarn
```

## Running tests

```bash
npx hardhat test
```

To run specific test:

```bash
npx hardhat test ./test/{test_file}
```
