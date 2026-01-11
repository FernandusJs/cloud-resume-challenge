resource "random_string" "db_account_name" {
  length  = 8
  lower   = true
  numeric = false
  special = false
  upper   = false
}
resource "azurerm_cosmosdb_account" "cosmodb_account" {
  name = "resume-cosmos-${random_string.db_account_name.result}"
  resource_group_name = azurerm_resource_group.cloud-resume.name
  location            = azurerm_resource_group.cloud-resume.location
  offer_type         = "Standard"
  kind = "GlobalDocumentDB"
  geo_location {
    location = azurerm_resource_group.cloud-resume.location
    failover_priority = 0
  }
    consistency_policy {
        consistency_level = "Session"
    }
    capabilities {
      name = "EnableServerless"
    }
}

resource "azurerm_cosmosdb_sql_database" "resume_db" {
  name = "ResumeData"
  resource_group_name = azurerm_resource_group.cloud-resume.name
  account_name = azurerm_cosmosdb_account.cosmodb_account.name
}
resource "azurerm_cosmosdb_sql_container" "counter_container" {
  name = "Counter"
  resource_group_name = azurerm_resource_group.cloud-resume.name
  account_name = azurerm_cosmosdb_account.cosmodb_account.name
  database_name = azurerm_cosmosdb_sql_database.resume_db.name
  partition_key_paths = [ "/id" ]
}