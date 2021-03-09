# dt-contracts

[英文版](./README.md)

## 概览

本仓库提供了五个合约功能，包括权限管理、资产方注册、数据通证颁发授权、可信代码模版发布以及多方计算任务市场。链上仅存储资产标识符，所有资产元数据都存储在IPFS当中。数据聚合方可生成可组合数据通证，在链上记录资产标识符间的层叠关系。数据应用方可发起链上任务，并请求链下计算。当前版本由机构充当聚合方、应用方，用户资产颁发也由机构完成，但资产授权计算由用户独立完成。

## 运行流程

### 准备工作

首先需部署Alaya私有网络，并安装alaya-truffle。推荐使用我们提供的platon.json文件来部署私链，其中内置了四个账户和金额。第一个账户作为合约部署方，即系统管理员，已配置在truffle-config.js中。其他三个账户将在DataToken SDK的其他模块测试中使用到。还需填充配置文件中的node0-pubkey，node0-blspubkey, 参考Platon官方的[启动教程](https://devdocs.platon.network/docs/en/Build_Private_Chain/)

系统管理员账户：
```
公钥: atp15t2w6p56y3auh0kqxl72mkxr5vzmfeqfyqk355
私钥: 4472aa5d4e2efe297784a3d44d840c9652cdb7663e22dedd920958bf6edfaf7e
```

### 合约部署

编译合约，已内置在./artifacts中：
```
$ git clone https://github.com/ownership-labs/dt-contracts
$ cd dt-contracts
$ alaya-truffle compile
```

解锁内置系统账户：
```
$ alaya-truffle console
$ web3.platon.personal.importRawKey("4472aa5d4e2efe297784a3d44d840c9652cdb7663e22dedd920958bf6edfaf7e","123");
$ web3.platon.personal.unlockAccount('atp15t2w6p56y3auh0kqxl72mkxr5vzmfeqfyqk355','123',999999);
```

部署合约到私链：
```
alaya-truffle migrate --reset
```

将输出的合约地址填充到./artifacts/address.json中，其他模块将使用到./artifacts中的合约abi和address