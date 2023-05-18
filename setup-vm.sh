#!/bin/bash 

groupName="testVMGroup-$(shuf -i 1-9 -n 1)"
az group create --name $groupName --location eastus

az vm create \
  --resource-group $groupName \
  --name ubuntu2010 \
  --image Canonical:0001-com-ubuntu-server-hirsute-daily:21_04-daily:21.04.202103160 \
  --custom-data cloud-init.txt \
  --admin-username azureuser \
  --size Standard_A0 \
  --generate-ssh-keys 


az vm open-port --port 22,80,443 --resource-group $groupName --name ubuntu2010