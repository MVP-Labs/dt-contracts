#!/usr/bin/env bash

# if there's no local ipfs repo, initialize one
if [ ! -d "$HOME/.ipfs" ]; then
  npx go-ipfs init
fi

echo "Running IPFS and development blockchain"
seed='brass bus same payment express already energy direct type have venture afraid'
run_eth_cmd="npx ganache-cli -d -m $seed"
run_ipfs_cmd="npx go-ipfs daemon"

npx concurrently -n eth,ipfs -c yellow,blue "$run_eth_cmd" "$run_ipfs_cmd"


