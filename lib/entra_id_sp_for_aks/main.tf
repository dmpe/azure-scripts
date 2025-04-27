locals {
  name_prefix = "aks-rg"
}

data "azuread_client_config" "current" {}

# Create resource group
resource "azurerm_resource_group" "main" {
  name     = "${local.name_prefix}-resources"
  location = "westeurope"
}

# Create Azure AD Application
resource "azuread_application" "main" {
  display_name = "${local.name_prefix}-principal"
}

# Create Service Principal associated with the Azure AD App
resource "azuread_service_principal" "main" {
  client_id                    = azuread_application.main.client_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
}

# Generate random string to be used for service principal password
resource "random_string" "password" {
  length = 32
}

# Create service principal password
resource "azuread_application_password" "main" {
  application_id = azuread_application.main.id
}

# Create virtual network (VNet)
resource "azurerm_virtual_network" "main" {
  name                = "${local.name_prefix}-network"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.240.0.0/16"]
}

# Create AKS subnet to be used by nodes and pods
resource "azurerm_subnet" "aks" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.240.1.0/24"]
}

# Not working
# Grant AKS service principal access to join AKS subnet
# resource "azurerm_role_assignment" "subnet" {
#   scope                = "${azurerm_subnet.aks.id}"
#   role_definition_name = "Network Contributor"
#   principal_id         = "${azuread_service_principal.main.id}"
# }

# # Grant AKS service principal access to manage network resources outside the node resource group
# resource "azurerm_role_assignment" "main" {
#   scope                = "${azurerm_resource_group.main.id}"
#   role_definition_name = "Network Contributor"
#   principal_id         = "${azuread_service_principal.main.id}"
# }

# Create Kubernetes cluster (AKS)
resource "azurerm_kubernetes_cluster" "main" {
  name                         = "${local.name_prefix}-cluster"
  location                     = azurerm_resource_group.main.location
  resource_group_name          = azurerm_resource_group.main.name
  dns_prefix                   = local.name_prefix
  sku_tier                     = "Free"
  node_os_upgrade_channel      = "NodeImage"
  image_cleaner_enabled        = true
  image_cleaner_interval_hours = 80

  network_profile {
    network_plugin      = "azure"
    network_policy      = "calico"
    network_plugin_mode = "overlay"
    pod_cidr            = "192.168.0.0/16"
    service_cidr        = "10.4.0.0/16"
    dns_service_ip      = "10.4.0.10" # must be within service_cidr
  }
  azure_active_directory_role_based_access_control {
    admin_group_object_ids = [""]
    azure_rbac_enabled     = true
  }
  automatic_upgrade_channel = "stable"
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
  default_node_pool {
    name                        = "systeool2"
    node_count                  = 2
    auto_scaling_enabled        = false
    vm_size                     = "Standard_D2s_v4"
    node_public_ip_enabled      = false
    max_pods                    = 250
    os_disk_size_gb             = 50
    os_sku                      = "Ubuntu"
    vnet_subnet_id              = azurerm_subnet.aks.id
    temporary_name_for_rotation = "tempsysrot1"
  }

  identity {
    type = "SystemAssigned"
  }
  workload_identity_enabled = true
  oidc_issuer_enabled       = true
}


# Create Public IP address outside the node resource group
# resource "azurerm_public_ip" "egress" {
#   name                = "aks-egress"
#   location            = "${azurerm_kubernetes_cluster.main.location}"
#   resource_group_name = "${azurerm_resource_group.main.name}"
#   allocation_method   = "Static"
# }
