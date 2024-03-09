#!/bin/bash 
# https://azureprice.net/regions

groupName="vault-experiment123"
VMName="ubuntu-testing"
VMSize="Standard_B2s"
region="northcentralus"

# az group create --name $groupName --location $region

# az vm create \
#   --resource-group $groupName \
#   --name "${VMName}-1" \
#   --accept-term \
#   --image "Canonical:0001-com-ubuntu-server-mantic:23_10-gen2:latest" \
#   --custom-data ./cloud-init.txt \
#   --admin-username azureuser \
#   --size $VMSize \
#   --public-ip-address-dns-name testvault1 \
#   --generate-ssh-keys \
#   --public-ip-sku Standard

# az vm open-port --port 22 --resource-group $groupName --name "${VMName}-1"

# az vm create \
#   --resource-group $groupName \
#   --name "${VMName}-2" \
#   --accept-term \
#   --image "Canonical:0001-com-ubuntu-server-lunar:23_04-gen2:latest" \
#   --custom-data ./cloud-init.txt \
#   --admin-username azureuser \
#   --size $VMSize \
#   --public-ip-address-dns-name testvault2 \
#   --generate-ssh-keys \
#   --public-ip-sku Standard

# az vm open-port --port 22 --resource-group $groupName --name "${VMName}-2"

