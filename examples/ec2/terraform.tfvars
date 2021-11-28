region = "us-east-1"

namespace = "stemaway"

environment = "ec2"

name = "nf-rnaseq"

max_vcpus = 256

# If you want to supply your own VPC/Subnets mark these as false
use_default_vpc = true
use_default_subnets = true
type = "EC2"