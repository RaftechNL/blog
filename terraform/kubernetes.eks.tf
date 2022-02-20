locals {
  eks_cluster_name = "my-eks-demo" #TODO: Consider changing :) 
}

module "eks" {
  source = "./modules/terraform-aws-func-kubernetes"

  cluster_name= local.eks_cluster_name

  vpc_id    = module.vpc.vpc_id
  vpc_cidrs = module.vpc.vpc_cidr_block

  subnets_private = module.vpc.private_subnets
  subnets_public  = module.vpc.public_subnets

  create_internal_nlb = true
  create_external_alb = true

  map_roles = [
    {
      rolearn  = "arn:aws:iam::123456789:role/SomeRoleToMap" # Adapt to your needs.
      username = "SomeUserName"
      groups   = ["system:masters"]
    }
  ]

  extra_worker_groups = [
    {
      name          = "cluster-addons"
      instance_type = "c5.2xlarge"

      asg_desired_capacity = "3"
      asg_max_size         = "3"
      asg_min_size         = "3"

      kubelet_extra_args = "--node-labels=node.kubernetes.io/lifecycle=on-demand,k8s.demo.io/workload-type=cluster-addons"

      tags = [
        {
          "key"                 = "ec2-lifecycle"
          "propagate_at_launch" = "true"
          "value"               = "on-demand"
        },
        {
          "key"                 = "eks-worker-group"
          "propagate_at_launch" = "true"
          "value"               = "cluster-addons"
        },
      ]
    },
  ]

  whitelist_external = {

    "aws-nlb-ext-healthcheck" = {
      description = "aws-nlb-ext-healthcheck"
      from_port   = 31080
      to_port     = 31080
      protocol    = "tcp"
      cidr_blocks = [module.vpc.vpc_cidr_block]
    }

    "your-ip-home" = {
      description = "ip-home"
      from_port   = 0
      to_port     = 65000
      protocol    = "tcp"
      cidr_blocks = ["1.2.3.4/32"] #TODO: Modify to your IP or allow all :)
    }

  }

  configuration_nlb = {
    "ext" = {
      port_ingress = 31443

      port_health = 31080
      path_health = "/aws-nlb-ext-healthcheck" # Will depend how you will configure NGINX Ingress
    }
    "int" = {
      port_ingress = 30443

      port_health = 30080
      path_health = "/aws-nlb-int-healthcheck" # Will depend how you will configure NGINX Ingress
    }
  }

  cluster_version = "1.21" # Latest available to us at the time of writing

  tags = {
    "demo" = "yes"
  }

}