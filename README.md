# cVote - Decentralized Voting Contract on Celo

[![Built with Foundry](https://img.shields.io/badge/Built%20with-Foundry-FF6B35)](https://getfoundry.sh/)
[![Celo Network](https://img.shields.io/badge/Network-Celo-35D07F)](https://celo.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A secure, gas-efficient voting smart contract built for the Celo blockchain using Foundry. This contract enables decentralized polls with customizable options, deadlines, and owner-controlled creation.

## 🚀 Features

- **Decentralized Polls**: Create and participate in on-chain voting
- **Flexible Configuration**: Owner can restrict poll creation or allow anyone to create polls
- **Deadline Support**: Optional voting deadlines for time-sensitive polls
- **Vote Integrity**: One-vote-per-address enforcement with on-chain tracking
- **Gas Optimized**: Custom errors and efficient data structures
- **Celo Compatible**: Deployed and tested on Celo Sepolia testnet

## 📋 Prerequisites

- [Foundry](https://getfoundry.sh/) - Ethereum development toolkit
- [Git](https://git-scm.com/) - Version control

## 🛠️ Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd CeloVoting
   ```

2. **Install dependencies:**
   ```bash
   forge install
   ```

3. **Set up environment:**
   - Copy `.env.example` to `.env` and configure your settings
   - Ensure your keystore is set up for deployment

## 🧪 Testing

Run the comprehensive test suite:

```bash
forge test
```

Run tests with gas reporting:

```bash
forge test --gas-report
```

Run coverage analysis:

```bash
forge coverage
```

## 🚀 Deployment

### Local Development
Start a local Anvil node:

```bash
anvil
```

### Testnet Deployment (Celo Sepolia)

1. **Configure your keystore:**
   ```bash
   cast wallet import defaultKey --interactive
   ```

2. **Deploy to Celo Sepolia:**
   ```bash
   forge script script/DeploycVote.s.sol --rpc-url celo_sepolia --account defaultKey --broadcast --verify
   ```

The contract will be automatically verified on Celoscan.

## 📖 Usage

### Creating a Poll

```solidity
// Example: Create a poll with 3 options and no deadline
cVote.createPoll(
    "Best Blockchain?",           // title
    "Vote for your favorite",     // description
    ["Ethereum", "Celo", "Solana"], // options
    0                            // no deadline
);
```

### Voting

```solidity
// Vote for option index 1 (Celo)
cVote.vote(pollId, 1);
```

### Getting Results

```solidity
(string[] memory options, uint256[] memory votes) = cVote.getResults(pollId);
```

## 🏗️ Architecture

### Contract Structure

- **cVote.sol**: Main voting contract with poll creation, voting, and result retrieval
- **DeploycVote.s.sol**: Foundry deployment script
- **cVote.t.sol**: Comprehensive test suite with 16 test cases

### Key Security Features

- Custom errors for gas efficiency
- Checks-effects-interactions pattern
- Input validation and access control
- One-vote-per-address enforcement
- Deadline and poll closure checks

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

### Development Guidelines

- Follow Solidity best practices and security patterns
- Write comprehensive tests for new features
- Update documentation for API changes
- Ensure all tests pass before submitting

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Links

- [Celo Documentation](https://docs.celo.org/)
- [Foundry Book](https://book.getfoundry.sh/)
- [Celoscan Sepolia Explorer](https://sepolia.celoscans.com/)

## 🙏 Acknowledgments

- Built following industry-standard secure smart contract patterns
- Inspired by real-world voting systems and DAO governance
- Thanks to the Celo community for blockchain infrastructure

---

**Note**: This is a learning project demonstrating secure smart contract development. Not intended for production use without additional audits and testing.
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
