# dt-contracts

[中文版](./README_CN.md)

## Overview

This project implements five smart contracts, including RoleController, AssetProvider, OpTemplate, DTFactory and TaskMarket. Given an asset (e.g., dataset, computation, algorithm), only its identifier is stored on the chain, and the asset metadata is stored in the decentralized storage network, IPFS/Filecoin in our case. Data aggregators can generate composable data tokens and record the hierachical permission grants on the chain. Data demanders can create tasks on-chain, and solvers can submit jobs for off-chain data collaboration. Currently, trusted entities (e.g., enterprizes) act as data aggregators, demanders and solvers. Although the user assets are issued by trusted entities, the permission grants of assets can be approved only by the user.

## Play With It

### prerequisites

You need to deploy the Alaya private network and install the alaya-truffle toolkit. Please refer to Platon's official documentations, see [Build_Private_Chain](https://devdocs.platon.network/docs/zh-CN/Build_Private_Chain/). 

It is recommended to use the platon.json file we provide, in which four accounts and their balances are predefined. The first account is used as the contract deployer, which is configured in the truffle-config.js file. You can consider it as the system account. The other three accounts will be used for tests of DataToken SDK. 

System account：
```
public key:  atp15t2w6p56y3auh0kqxl72mkxr5vzmfeqfyqk355
private key: 4472aa5d4e2efe297784a3d44d840c9652cdb7663e22dedd920958bf6edfaf7e
```

### contract deployment

First, compile the datatoken contracts. The abis are stored in ./artifacts：
```
$ git clone https://github.com/ownership-labs/dt-contracts
$ cd dt-contracts
$ alaya-truffle compile
```

Then, unlock the system account：
```
$ alaya-truffle console
$ web3.platon.personal.importRawKey("4472aa5d4e2efe297784a3d44d840c9652cdb7663e22dedd920958bf6edfaf7e","123");
$ web3.platon.personal.unlockAccount('atp15t2w6p56y3auh0kqxl72mkxr5vzmfeqfyqk355','123',999999);
```

Finally, deploy the contracts to the Alaya network：
```
alaya-truffle migrate --reset
```

You can see the contract addresses from the outputs. You need to fill them into the ./artifacts/address.json file. The abis and address file are required if you want to interact with other datatoken modules.