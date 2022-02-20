locals {
  region = "eu-west-1"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> v3"


  name = "vpc-demo"
  cidr = "10.10.0.0/16"

  azs             = ["${local.region}a", "${local.region}b", "${local.region}c"]
  private_subnets = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
  public_subnets  = ["10.10.101.0/24", "10.10.102.0/24", "10.10.103.0/24"]

  enable_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  private_subnet_tags = {
    "vpc"                                               = "vpc-demo"
    "kubernetes.io/cluster/${local.eks_cluster_name}"   = "owned"
  }

  public_subnet_tags = {}

}