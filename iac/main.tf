# Create a random name for the resource group using random_pet
resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

# Create a resource group using the generated random name
resource "azurerm_resource_group" "cloud-resume" {
  location = var.resource_group_location
  name     = random_pet.rg_name.id
}
#generate random string for storage account name
resource "random_string" "storage_account_name" {
  length  = 8
  lower   = true
  numeric = false
  special = false
  upper   = false
}
resource "cloudflare_dns_record" "resume_dns" {
  ttl = 1
  zone_id = var.cloudflare_zone_id
  name    = "www" 
  content = azurerm_storage_account.storage_account.primary_web_host
  type    = "CNAME"
  proxied = true #enables cdn & ssl
}
resource "cloudflare_dns_record" "asverify" {
  ttl = 1
  zone_id = var.cloudflare_zone_id
  name    = "asverify.www" 
  content = "asverify.${azurerm_storage_account.storage_account.primary_web_host}"
  type    = "CNAME"
  proxied = false 
}

#create storage account for static website hosting
resource "azurerm_storage_account" "storage_account" {
  resource_group_name = azurerm_resource_group.cloud-resume.name
  location            = azurerm_resource_group.cloud-resume.location

  name = random_string.storage_account_name.result

  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  custom_domain {
    name           = "www.nand-beeckx.dev"
    use_subdomain  = true # Set to true to use the asverify method
  }

}
#enable static website hosting on the storage account
resource "azurerm_storage_account_static_website" "static_website" {
  storage_account_id = azurerm_storage_account.storage_account.id
  error_404_document = "404.html"
  index_document     = "index.html"
}

resource "azurerm_storage_blob" "website_blob" {
  for_each = fileset("${path.module}/../frontend", "*")
  name = each.value
  storage_account_name = azurerm_storage_account.storage_account.name
  storage_container_name = "$web"
  type = "Block"
  source = "${path.module}/../frontend/${each.value}"
  depends_on = [azurerm_storage_account_static_website.static_website]
  content_type = "text/html"
}
locals {
  mime_types = {
    ".html" = "text/html"
    ".css"  = "text/css"
    ".js"   = "application/javascript"
  }
}
resource "random_id" "random" {
  byte_length = 8
}


resource "cloudflare_ruleset" "root_to_www_redirect" {
  zone_id = var.cloudflare_zone_id
  name    = "Root to WWW Redirect"
  kind    = "zone"
  phase   = "http_request_dynamic_redirect"

  rules = [{
    description = "Redirect nand-beeckx.dev to www"
    expression  = "(http.host eq \"nand-beeckx.dev\")"
    action      = "redirect"
    
    action_parameters = {
      from_value = {
        status_code = 301
        target_url = {
          expression = "concat(\"https://www.nand-beeckx.dev\", http.request.uri.path)"
        }
        preserve_query_string = true
      }
    }
  }]
}