variable "kibana_api_key" {
  description = "Kibana API key"
  type        = string
  sensitive   = true
}

variable "kibana_endpoint" {
  description = "Kibana endpoint URL"
  type        = string
  sensitive = true
}