# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.14.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.81.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    virtual_machine {
      delete_os_disk_on_deletion = true
      skip_shutdown_and_force_delete = true
    }
  }
  subscription_id = "9c56d914-6a29-426a-a1fb-cac5e28886d1"

}
