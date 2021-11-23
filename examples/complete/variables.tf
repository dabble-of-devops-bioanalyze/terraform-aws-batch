variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "max_vcpus" {
  type    = number
  default = 8
}

variable "secrets_enabled" {
  type = bool
  default = true
}