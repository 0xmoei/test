#!/bin/bash

CHAINID="stationevm_1234-1"
KEYRING="test"
KEYALGO="eth_secp256k1"
HOMEDIR="$HOME/.evmosd1"
VAL_KEY="mykey1"

./build/station-evm keys unsafe-export-eth-key "$VAL_KEY" --keyring-backend "$KEYRING" --home "$HOMEDIR"
