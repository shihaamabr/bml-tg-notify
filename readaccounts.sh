#!/bin/bash
NUMBEROFACCOUNTS=$(cat .env | grep BML_ACCOUNTID | cut --complement -d "'" -f 1 |  cut -f1 -d "'" | wc -l)
i=0;
for account in `cat .env | grep BML_ACCOUNTID | cut --complement -d "'" -f 1 |  cut -f1 -d "'"`
do
   accountid[$i]=$account;
    i=$(($i+1));
SELECT=$(cat .env | grep BML_ACCOUNTID | cut --complement -d "'" -f 1 |  cut -f1 -d "'" | head -n$i | tail -n1)
echo $SELECT Selected
sleep 1
i=0
done
