#!/bin/bash

source "common.sh"

groupName="testVMGroup-$(shuf -i 1-9 -n 1)"
VMName="ubuntu-testing"
VMSize="Standard_B4als_v2"
region="centralindia"

create_rg $groupName $region
# create_vm $groupName $VMName $VMSize $region

# ssh-add /home/jm/.ssh/id_rsa

# ssh-keygen -f "/home/jm/.ssh/known_hosts" -R $fqdn_name
# echo azureuser@$fqdn_name

# ssh azureuser@$fqdn_name