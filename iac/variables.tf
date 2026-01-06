variable "resource_group_location" {
  type        = string
  default     = "francecentral"
  description = "Location of the resource group."
}

variable "resource_group_name_prefix" {
  type        = string
  default     = "rg-cloud-resume"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}
variable "subscription_id" {
  description = "The Azure Subscription ID (GUID)"
  type        = string
  sensitive   = true #value as sensitive in plans/outputs
}

variable "cloudflare_api_token" {
  description = "Cloudflare API key"
  type = string
  sensitive = true
}
variable "cloudflare_zone_id" {
  type = string
}