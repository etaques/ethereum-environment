#!/bin/sh

#geth init  --datadir /root/.ethereum/ /root/holesky/genesis.json

apk update && apk add jq

bootnodes=$(cat /root/holesky/enodes.txt)
network_id=$(jq -r '.config.chainId' /root/holesky/genesis.json)

exec geth \
  --mainnet \
  --port=30303 \
#  --bootnodes "$bootnodes"
  --http.addr=0.0.0.0
  --http.port=8545
  --http
  --http.api=engine,eth,web3,txpool,net,debug
  --http.corsdomain="*"
  --http.vhosts="*"
  --ws
  --ws.addr=0.0.0.0
  --ws.port=8546
  --ws.api=engine,eth,web3,txpool,net,debug
  --ws.origins='*'
  --syncmode=snap
  --metrics
  --metrics.addr=0.0.0.0
  --metrics.port=8300
  --authrpc.addr=0.0.0.0
  --authrpc.port=8551
  --authrpc.vhosts="*"
  --authrpc.jwtsecret="/root/.jwt/jwtsecret"
  --verbosity=3
  --nousb
  --graphql
  --graphql.corsdomain='*'
  --graphql.vhosts='*'
  --nodiscover
