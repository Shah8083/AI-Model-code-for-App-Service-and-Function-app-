# Define the Microsoft Azure Provider
provider "azurerm" {
  features {}
}
# Define the Resource Group
resource "azurerm_resource_group" "test-rg-ai" {
  name     = "test-rg-ai"
  location = "West Europe"
}

# Define the App Service Plan
resource "azurerm_app_service_plan" "ai-app-service" {
  name                = "ai-app-service-plan"
  location            = azurerm_resource_group.test-rg-ai.location
  resource_group_name = azurerm_resource_group.test-rg-ai.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}
# Define the App Service
resource "azurerm_app_service" "aiappservice" {
  name                = "my-ai-app-service"
  location            = azurerm_resource_group.test-rg-ai.location
  resource_group_name = azurerm_resource_group.test-rg-ai.name
  app_service_plan_id = azurerm_app_service_plan.ai-app-service.id

  site_config {
    dotnet_framework_version = "v4.0"
    scm_type                 = "LocalGit"
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=some-server.mydomain.com;Integrated Security=SSPI"
  }
}

 # Define the Function App
resource "azurerm_storage_account" "storageaccountaitest12" {
  name                     = "storageaccountaitest12"
  resource_group_name      = azurerm_resource_group.test-rg-ai.name
  location                 = azurerm_resource_group.test-rg-ai.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
 
 # Define the Service plan
resource "azurerm_app_service_plan" "ai-service-plan" {
  name                = "ai-service-plan"
  resource_group_name = azurerm_resource_group.test-rg-ai.name
  location            = azurerm_resource_group.test-rg-ai.location
  kind                = "FunctionApp"
  reserved             = true

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

# Define the Function App 
resource "azurerm_function_app" "myfunctionappai" {
  name                       = "myfunctionappai"
  resource_group_name        = azurerm_resource_group.test-rg-ai.name
  location                   = azurerm_resource_group.test-rg-ai.location
  app_service_plan_id        = azurerm_app_service_plan.ai-app-service.id
  storage_account_name       = azurerm_storage_account.storageaccountaitest12.name
  storage_account_access_key = azurerm_storage_account.storageaccountaitest12.primary_access_key
}