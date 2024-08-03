#!/bin/bash

openssl rand -hex 32 | tr -d "\n" > "jwtsecret"
mkdir -p ./geth
mkdir -p ./geth/jwt
mv jwtsecret ./geth/jwt/
