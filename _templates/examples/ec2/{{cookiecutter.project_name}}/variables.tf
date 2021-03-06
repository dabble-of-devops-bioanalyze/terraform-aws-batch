variable "region" {
  type    = string
  default = "us-east-1"
}

variable "max_vcpus" {
  type    = number
  default = 256
}

variable "secrets_enabled" {
  type    = bool
  default = true
}

variable "type" {
  description = "Type of cluster to create."
  type        = string
  default     = "FARGATE"
}

variable "run_tests" {
  description = "Run the python tests at the end the module"
  type = bool
  default = false
}