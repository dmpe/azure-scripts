#!/bin/bash 
# https://azureprice.net/regions

groupName="testVMGroup-$(shuf -i 1-9 -n 1)"
VMName="ubuntu-testing"
VMSize="Standard_B2s"
region="westus3"

az group create --name $groupName --location $region

az vm create \
  --resource-group $groupName \
  --name $VMName \
  --accept-term \
  --image "Canonical:ubuntu-24_10:server:latest" \
  --admin-username azureuser \
  --size $VMSize \
  --public-ip-address-dns-name testvmalfadogmarker \
  --generate-ssh-keys \
  --public-ip-sku Standard

sleep 10

az vm open-port --port 22 --resource-group $groupName --name $VMName

fqdn_name=$(az network public-ip list --query "[].dnsSettings.fqdn" | gojq -r '.[]')

ssh-add /home/jm/.ssh/id_rsa

ssh-keygen -f "/home/jm/.ssh/known_hosts" -R $fqdn_name
echo azureuser@$fqdn_name

ssh azureuser@$fqdn_name
