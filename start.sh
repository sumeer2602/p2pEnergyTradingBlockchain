#!/bin/bash

nodes=$1
index=$nodes-1
echo $nodes
mkdir ForIBFT
cd ForIBFT

istanbul setup --num $nodes --nodes --quorum --save --verbose

# cd ForIBFT
# mkdir Accounts
# cd Accounts
geth account new --datadir Accounts
files=(*)

address=$(jq '.address' ${files[0]})

echo $address
echo 'Copy the above address and paste it into genesis.json and allocate some balance'
echo 'Press enter when done: '
read enter

# cd ..
# for i in {0..($index)}
# while [$i -le $index]
# i=0
for ((i=0; i<$nodes; i++))
do 
    echo "here"
    mkdir -p Node$i/data
    cp genesis.json Node$i   
    # ((i++)) 
done

echo 'Please open static.json file and edit IP addresses and Port Numbers'
echo 'Press enter when done: '
read enter

# i=0
# for i in {0..($index)}
# while [$i -le $($nodes-1)]
for ((i=0; i<$nodes; i++))
do 
    cp static-nodes.json Node$i/data
    cp $i/nodekey  Node$i/data
    # ((i++)) 
done

# initializing blockchain
# for i in {0..($index)}
# i=0
# while [$i -le $($nodes-1)]
for ((i=0; i<$nodes; i++))
do 
    cd Node$i
    geth --datadir data init ./genesis.json
    cd ../Accounts/keystore
    dir=(*)
    cd ../../Node$i
    # echo 'hello'
    # echo ${dir[0]}
    cp ../Accounts/keystore/${dir[0]} data/keystore
    cd ..
    # ((i++)) 
done

# i=0 
# for i in {0..($index)}
# while [$i -lt $nodes]
# while [$i -le $($nodes-1)]
for ((i=0; i<$nodes; i++))
do 
    cd Node$i
    gnome-terminal -- sh -c "bash -c \"PRIVATE_CONFIG=ignore geth --datadir data --nodiscover --istanbul.blockperiod 5 --syncmode full --mine --miner.threads 1 --verbosity 5 --networkid 10 --rpc --rpcaddr 127.0.0.1 --rpcport 2200$i --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum,istanbul --emitcheckpoints --allow-insecure-unlock --port 3030$i; exec bash\"" 
    cd ..
    # ((i++))
done 




# echo jq ''