variable "cloudsmith_api_key" {
  description = "Cloudsmith API Key"
  type        = string
  sensitive   = true
}

variable "organization" {
  description = "Cloudsmith organization name"
  type        = string
}
