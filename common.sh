#!/bin/bash

create_vm() {
    az vm create \
    --resource-group $1 \
    --name $2 \
    --accept-term \
    --image "canonical:0001-com-ubuntu-server-mantic:23_10-gen2:latest" \
    --admin-username azureuser \
    --size $3 \
    --public-ip-address-dns-name $4 \
    --generate-ssh-keys \
    --public-ip-sku Standard

    az vm open-port --port 22 --resource-group $1 --name $2

    fqdn_name=$(az network public-ip list --query "[].dnsSettings.fqdn" | gojq -r '.[]')
    echo $fqdn_name
}


create_rg() {
    az group create --name $1 --location $2
}