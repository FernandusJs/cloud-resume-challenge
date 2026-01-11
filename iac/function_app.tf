#random name for storage acc
resource "random_string" "func_name" {
  length  = 8
  lower   = true
  numeric = false
  special = false
  upper   = false
}

#Storage account for function app
resource "azurerm_storage_account" "func_storage" {
    name                     = "funcstorage${random_string.func_name.result}"
    resource_group_name      = azurerm_resource_group.cloud-resume.name
    location                 = azurerm_resource_group.cloud-resume.location
    account_tier             = "Standard"
    account_replication_type = "LRS"
}
#Function app plan = consumption, linux
resource "azurerm_service_plan" "func_plan" {
  name = "service-plan-${random_string.func_name.result}"
  location = azurerm_resource_group.cloud-resume.location
  resource_group_name = azurerm_resource_group.cloud-resume.name
  os_type = "Linux"
  sku_name = "Y1"
}

#Function app
resource "azurerm_linux_function_app" "function_app" {
    name = "resume-api-${random_string.func_name.result}"
    location = azurerm_resource_group.cloud-resume.location
    resource_group_name = azurerm_resource_group.cloud-resume.name

    storage_account_name = azurerm_storage_account.func_storage.name
    storage_account_access_key = azurerm_storage_account.func_storage.primary_access_key

    service_plan_id = azurerm_service_plan.func_plan.id

    site_config {
      application_stack {
        python_version = "3.11"
      }
      cors {
        allowed_origins = [
            "https://www.nand-beeckx.dev",
            "https://nand-beeckx.dev",
            "https://portal.azure.com"
        ]
      }
    }
    app_settings = {
        "CosmosDbConnectionString" = azurerm_cosmosdb_account.cosmodb_account.primary_sql_connection_string
  }
}