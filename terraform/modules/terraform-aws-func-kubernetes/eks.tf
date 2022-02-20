
locals {

  cluster_name = var.cluster_name

  workers_role_name = var.workers_role_name != "" ? var.workers_role_name : "${local.resource_prefix}-eks-worker-role"

  tags_asg_module = [for t, v in local.tags_app_module : {
    key                 = t
    value               = v
    propagate_at_launch = true
    }
  ]
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 17.0"

  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version

  vpc_id  = var.vpc_id
  subnets = var.subnets_private

  cluster_enabled_log_types = var.cluster_enabled_log_types

  enable_irsa                     = true
  write_kubeconfig                = false
  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access

  cluster_encryption_config = [
    {
      provider_key_arn = aws_kms_key.eks.arn
      resources        = ["secrets"]
    }
  ]

  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  workers_role_name = local.workers_role_name

  workers_group_defaults = {
    root_encrypted = true

    subnets       = var.subnets_private
    instance_type = "c5.xlarge"

    # By definition 3 as we have set up our cluster with 3 AZ
    asg_desired_capacity = "3"
    asg_max_size         = "3"
    asg_min_size         = "3"

  }


  # When condition = true, ?: evaluates normally. When condition = false, ?: goes to false condition, fails on tomap(false), then try() handles this and finally returns fallback which joined object
  # worker_groups = try(lookup(var.extra_worker_groups[0],null) == null ? var.base_worker_groups : tomap(false), concat(var.base_worker_groups,var.extra_worker_groups))

  worker_groups = concat(
    [
      {
        name = "ingress-ext"

        subnets = var.subnets_public

        kubelet_extra_args = "--node-labels=networking.demo.io/ingress-type=ext,networking.demo.io/ingress=true,node.kubernetes.io/lifecycle=on-demand --register-with-taints=networking.demo.io/ingress-type=ext:NoSchedule"

        additional_security_group_ids = [aws_security_group.nlb_external.id]

        target_group_arns = module.nlb_external.target_group_arns

        tags = concat(
          local.tags_asg_module,
          [
            {
              "key"                 = "ec2-lifecycle"
              "propagate_at_launch" = "true"
              "value"               = "on-demand"
            },
            {
              "key"                 = "eks-worker-group"
              "propagate_at_launch" = "true"
              "value"               = "ingress-ext"
            },
          ]
        )
      },
      {
        name = "ingress-int"

        kubelet_extra_args = "--node-labels=networking.demo.io/ingress-type=int,networking.demo.io/ingress=true,node.kubernetes.io/lifecycle=on-demand --register-with-taints=networking.demo.io/ingress-type=int:NoSchedule"

        additional_security_group_ids = [aws_security_group.nlb_internal.id]

        target_group_arns = module.nlb_internal.target_group_arns

        tags = concat(
          local.tags_asg_module,
          [
            {
              "key"                 = "ec2-lifecycle"
              "propagate_at_launch" = "true"
              "value"               = "on-demand"
            },
            {
              "key"                 = "eks-worker-group"
              "propagate_at_launch" = "true"
              "value"               = "ingress-int"
            },
          ]
        )
      }
    ],
    var.extra_worker_groups
  )

  map_users = []
  map_roles = var.map_roles

  tags = merge(
    {
      tf-module     = "terraform-aws-modules/eks/aws"
      tf-module-ver = "17.0"
    },
    local.tags_app_module
  )
}
