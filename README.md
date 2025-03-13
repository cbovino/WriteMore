## WriteMore

WriteMore is designed for software engineers who want to stay committed to coding. The goal is simple: help engineers write more code by allowing them to bet on themselves.

### How It Works

- A user commits to writing code daily and uploading it to their GitHub account for a set number of consecutive days.
- They stake ETH (or Polygon) as a financial commitment.
- If they maintain their streak, their ETH is returned.
- If they break their streak, their ETH is donated to a predefined list of charities.

### Smart Contract Logic

#### makeCommitment
- Creates a new commitment for a user to stake their ETH with specific deadlines.
- Accepts the user's GitHub username, the amount of ETH, the last day of their commitment, and an address for their charity of choice.

#### checkCommitment
- Checks if the user has missed any days in their commitments by comparing dates maintained within the smart contract.
- If the user hasn't missed any previous days, it will make a check to GitHub through a Chainlink function to check the current day's commits and update the state for that user's commitment.
- If the user has missed any previous days, it will send off the staked ETH to the desired charity or donation account.

#### returnCommitment
- On the final day of a commitment, this function performs the same check as checkCommitment to validate if the user has missed any days in their commitment.

### The Challenge of Off-Chain Data

- The makeCommitment function is straightforward, leveraging built-in timestamp variables and doesn't require external data beyond the blockchain.
- checkCommitment is more complex because it relies on verifying data from an external source—GitHub.

### Using Chainlink Functions for Off-Chain Data

- Chainlink Functions provide a solution by enabling secure off-chain computation while preserving decentralization principles.
- checkCommitment must use Chainlink's smart contract function client to request off-chain data and execute JavaScript code within the Chainlink Functions environment to check the GitHub activity.

### Hybrid Approach

- The smart contract remains lightweight and easier to maintain.
- External API requests and logic processing happen off-chain, reducing complexity.
- The system maintains decentralization by leveraging Chainlink Functions for data verification.

### Conclusion

The hybrid architecture of WriteMore highlights both the power and the challenges of Web3 development. While blockchains offer immutable, transparent execution, they need reliable off-chain data to interact with real-world events. Tools like Chainlink Functions bridge this gap, allowing us to build decentralized applications that can still leverage the vast amount of data and compute power available off-chain.

As WriteMore evolves, future improvements might include reducing reliance on centralized services, improving data verification methods, and exploring more decentralized oracles. For now, this hybrid approach strikes a balance between usability and decentralization — pushing the boundaries of what's possible with smart contracts.



## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```