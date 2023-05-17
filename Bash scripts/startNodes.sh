
nodes=$1
cd ForIBFT
for ((i=0; i<$nodes; i++))
do 
    cd Node$i
    gnome-terminal -- sh -c "bash -c \"PRIVATE_CONFIG=ignore geth --datadir data --nodiscover --istanbul.blockperiod 5 --syncmode full --mine --miner.threads 1 --verbosity 5 --networkid 10 --rpc --rpcaddr 127.0.0.1 --rpcport 2200$i --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum,istanbul --emitcheckpoints --allow-insecure-unlock --port 3030$i; exec bash\"" 
    cd ..
    # ((i++))
done 
