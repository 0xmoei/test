#!/bin/bash

CHAINID="stationevm_1234-2"
KEYRING="test"
KEYALGO="eth_secp256k1"
HOMEDIR="$HOME/.evmosd2"
VAL_KEY="mykey2"

./build/station-evm keys unsafe-export-eth-key "$VAL_KEY" --keyring-backend "$KEYRING" --home "$HOMEDIR"
