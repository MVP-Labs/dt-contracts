# dt-contracts

[中文版](./README_CN.md)

## Overview

This project implements five smart contracts, including RoleController, AssetProvider, OpTemplate, DTFactory and TaskMarket. Given an asset (e.g., dataset, computation, algorithm), only its identifier is stored on the chain, and the asset metadata is stored in the decentralized storage network, IPFS/Filecoin in our case. Data aggregators can generate composable data tokens and record hierachical permission grants on the chain. Data demanders can create tasks on-chain, and solvers can submit jobs for off-chain data collaboration. Currently, trusted entities (e.g., enterprizes) act as data aggregators, demanders and solvers. Although the user assets are issued by trusted entities, the permission grants of the assets can be approved only by the user.

## Play With It

### prerequisites

You need to deploy the Ethereum and Filecoin local environments. Here we recommend the ganache tools. The first account is used as the contract deployer, acting as the system account.
```
> npm install -g truffle
> npm install -g ganache-cli
> npm install -g ganache@filecoin
> npm install -g @ganache/filecoin
> ganache-cli -d -m 'brass bus same payment express already energy direct type have venture afraid'
> ganache filecoin
```

### contract deployment

Compile the datatoken contracts. The abis are stored in ./artifacts：
```
$ git clone https://github.com/ownership-labs/dt-contracts
$ cd dt-contracts
$ truffle compile
$ truffle migrate --network development
```

You can see the contract addresses from the outputs. You need to fill them into the `./artifacts/address.json` file. The abis and address file are required if you want to interact with other datatoken modules.