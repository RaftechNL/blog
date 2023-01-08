module "external_self_managed_node_group" {
  source  = "terraform-aws-modules/eks/aws//modules/self-managed-node-group"
  version = "~> 19.0"
  create  = var.create_nlb_external

  name                = "nodegroup-${local.name}-external"
  cluster_name        = local.name
  cluster_version     = "1.24"
  cluster_endpoint    = module.eks.cluster_endpoint
  cluster_auth_base64 = module.eks.cluster_certificate_authority_data

  subnet_ids = module.vpc.public_subnets

  vpc_security_group_ids = [
    module.eks.node_security_group_id,
    try(aws_security_group.nlb_external[0].id, null),
  ]

  iam_role_use_name_prefix = false
  iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore",
  }

  min_size      = 3
  max_size      = 3
  desired_size  = 3
  instance_type = "t3.large"

  bootstrap_extra_args = "--kubelet-extra-args '--node-labels=networking.raftech.io/ingress-type=ext,networking.raftech.io/ingress=true,node.kubernetes.io/lifecycle=on-demand --register-with-taints=networking.raftech.io/ingress-type=ext:NoSchedule'"

  target_group_arns = module.nlb_external.target_group_arns # our target group from our LoadBalancer module

  tags = {
    "owner" = "raf"
  }
}

module "internal_self_managed_node_group" {
  source  = "terraform-aws-modules/eks/aws//modules/self-managed-node-group"
  version = "v19.0.3"
  create  = var.create_nlb_internal

  name                = "nodegroup-${local.name}-internal"
  cluster_name        = local.name
  cluster_version     = "1.24"
  cluster_endpoint    = module.eks.cluster_endpoint
  cluster_auth_base64 = module.eks.cluster_certificate_authority_data

  subnet_ids = module.vpc.private_subnets

  vpc_security_group_ids = [
    module.eks.node_security_group_id,
    try(aws_security_group.nlb_internal[0].id, null),
  ]

  iam_role_use_name_prefix = false
  iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore",
  }

  min_size      = 3
  max_size      = 3
  desired_size  = 3
  instance_type = "t3.medium"

  bootstrap_extra_args = "--kubelet-extra-args '--node-labels=networking.raftech.io/ingress-type=int,networking.raftech.io/ingress=true,node.kubernetes.io/lifecycle=on-demand --register-with-taints=networking.raftech.io/ingress-type=int:NoSchedule'"

  target_group_arns = module.nlb_internal.target_group_arns

  tags = {
      "owner" = "raf"
    }
}