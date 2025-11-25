variable "do_token" {
  description = "DigitalOcean API token Dev environment"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "DigitalOcean region for resources"
  type        = string
  default     = "blr1"

}