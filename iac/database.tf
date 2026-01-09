resource "random_string" "db_account_name" {
  length  = 8
  lower   = true
  numeric = false
  special = false
  upper   = false
}
resource "azurerm_cosmosdb_account" "cosmodb_account" {
  name = random_string.db_account_name.result
  resource_group_name = azurerm_resource_group.cloud-resume.name
  location            = azurerm_resource_group.cloud-resume.location
  offer_type         = "Standard"
  kind = "GlobalDocumentDB"
  geo_location {
    location = azurerm_resource_group.cloud-resume
    failover_priority = 0
  }
    consistency_policy {
        consistency_level = "Session"
    }
}