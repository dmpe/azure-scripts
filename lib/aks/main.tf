resource "azurerm_resource_group" "rg" {
  name     = "aks-resources"
  location = "westus2"
}

resource "azurerm_virtual_network" "my_terraform_network" {
  name                = "aks-dev-vnet"
  address_space       = ["10.0.0.0/8"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "my_terraform_subnet_1" {
  name                 = "subnet-1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.my_terraform_network.name
  address_prefixes     = ["10.0.0.0/16"] # 64k IPs
}

resource "azurerm_kubernetes_cluster" "ask-cluster" {
  name                    = "aks1"
  location                = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  dns_prefix              = "myexampleaks1"
  sku_tier                = "Free"
  kubernetes_version      = "1.31.1"
  node_os_upgrade_channel = "NodeImage"
  image_cleaner_enabled   = true
  image_cleaner_interval_hours = 80
  azure_policy_enabled    = false
  azure_active_directory_role_based_access_control {
    admin_group_object_ids = ["903db71d-e2a8-45ae-8a69-36b4f3498671"]
    azure_rbac_enabled     = true
  }
  maintenance_window {
    allowed {
      day   = "Saturday"
      hours = [0, 23]
    }
  }

  maintenance_window_auto_upgrade {
    frequency   = "Weekly"
    interval    = 1
    duration    = 10
    day_of_week = "Saturday"
    start_time  = "01:00"
  }

  maintenance_window_node_os {
    frequency   = "Weekly"
    interval    = 1
    duration    = 10
    day_of_week = "Saturday"
    start_time  = "13:00"
  }

  tags = {
    Environment = "Test"
  }
  network_profile {
    network_plugin      = "azure"
    network_policy      = "calico"
    network_plugin_mode = "overlay"
    pod_cidr            = "192.168.0.0/16"
    service_cidr        = "10.4.0.0/16"
    dns_service_ip      = "10.4.0.10" # must be within service_cidr
  }

  default_node_pool {
    name                        = "systeool2"
    node_count                  = 2
    auto_scaling_enabled        = false
    vm_size                     = "Standard_DS2_v2"
    node_public_ip_enabled      = false
    max_pods                    = 250
    os_disk_size_gb             = 50
    os_sku                      = "Ubuntu"
    vnet_subnet_id              = azurerm_subnet.my_terraform_subnet_1.id
    temporary_name_for_rotation = "tempsysrot1"
  }

  automatic_upgrade_channel = "patch"

  identity {
    type = "SystemAssigned"
  }
}

