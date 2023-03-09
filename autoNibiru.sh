#!/bin/bash

ADDR="" # your address
VALADDR=""
URL="https://nibiru.api.explorers.guru/api/v1/validators"
PASS=""

UN=1000000
GAS=10000

TI=2

# check active status and reactive if node deactive

# curl $URL | jq '.[] | select(.moniker=="panther_dtc").bondStatus'| grep BondStatusBondeded

nibid query staking validator $VALADDR | grep BOND_STATUS_BONDED

if [[ $? -eq 1 ]]; then

        echo $PASS | nibid tx slashing unjail --broadcast-mode=block --from=wallet --chain-id=nibiru-itn-1 --gas=200000 --fees=80000unibi --yes


        echo "#########  unjailed node ########## "
        sleep $TI
fi

# check and claim all reward

REWARDS=$(nibid query distribution rewards $ADDR | grep amount | tr -dc '[. [:digit:]]' | awk '{print $NF}')
NIBI_REWARDS=$(awk '{print $1*$2}' <<<"${REWARDS} ${UN}")

if [[ $NIBI_REWARDS -gt 1000 ]]
then

        echo $PASS | nibid tx distribution withdraw-all-rewards --broadcast-mode=block --from=wallet --chain-id=nibiru-itn-1 --gas=200000 --fees=80000unibi --yes
        sleep $TI

fi

# add delegate

UNIBI_BAL=$(nibid query bank balances $ADDR --denom=unibi | grep amount | grep -o -E '[0-9]+')

NIBI_BAL=$(( $UNIBI_BAL / $UN ))
AMOUNT=$(( $UNIBI_BAL - $GAS ))


if [[ $AMOUNT -gt 100 ]]
then
        echo $PASS | nibid tx staking delegate $VALADDR ${AMOUNT}unibi --from=wallet --chain-id=nibiru-itn-1 --fees=9000unibi --yes
fi

