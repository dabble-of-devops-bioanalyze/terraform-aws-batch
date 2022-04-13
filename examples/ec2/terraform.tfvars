region = "us-east-1"

namespace = "bioanalyze"

environment = "ec2"

stage = "test"

name = "nf-rnaseq"

max_vcpus = 256

type = "EC2"

run_tests = true
# run_tests = false

ec2_key_pair = "stemaway-bioanalyze"