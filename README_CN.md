# dt-contracts

[英文版](./README.md)

## 概览

本仓库提供了五个合约功能，包括权限管理、资产方注册、数据通证颁发授权、可信代码模版发布以及多方计算任务市场。链上仅存储资产标识符，所有资产元数据都存储在IPFS当中。数据聚合方可生成可组合数据通证，在链上记录资产标识符间的层叠关系。数据应用方可发起链上任务，并请求链下计算。当前版本由机构充当聚合方、应用方，用户资产颁发也由机构完成，但资产授权计算由用户独立完成。

## 运行流程

### 准备工作

首先需部署Ethereum的本地测试环境，这里使用ganache-cli。ganache-cli的第一个账户作为合约部署方，即系统管理员。
```
$ ganache-cli -d -m 'brass bus same payment express already energy direct type have venture afraid'
```

### 合约部署

```
$ git clone https://github.com/ownership-labs/dt-contracts
$ cd dt-contracts
$ truffle compile
$ truffle migrate --network development
```

将输出的合约地址填充到./artifacts/address.json中，其他模块将使用到./artifacts中的合约abi和address