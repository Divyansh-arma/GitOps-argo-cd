variable "do_token" {
  description = "DigitalOcean API token Prod environment"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "DigitalOcean region for resources"
  type        = string
  default     = "blr1"

}