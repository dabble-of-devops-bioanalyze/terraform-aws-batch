provider "aws" {
  region = var.region
}

module "example" {
  source = "../.."

  region     = var.region
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids
  max_vcpus  = var.max_vcpus
  secrets_enabled =  var.secrets_enabled

  context = module.this.context
}
