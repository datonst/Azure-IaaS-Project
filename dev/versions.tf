# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.81.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  subscription_id = "ef78e1b2-a4fb-4bc4-bbed-2e38ee45a7ba"
}
