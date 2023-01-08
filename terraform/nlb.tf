locals {
  external_sg_name = "${local.name}-external"
  internal_sg_name = "${local.name}-internal"  
}

module "nlb_external" {
  source    = "terraform-aws-modules/alb/aws"
  version   = "8.2.1"
  create_lb = var.create_nlb_external

  name = "nlb-ext-${local.name}"

  load_balancer_type = "network"
  internal           = false
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets

  enable_cross_zone_load_balancing = true
  enable_deletion_protection       = false # In production you should enable this

  target_groups = [
    # With the following target group we are using SSL passthrough and we will make sure 
    # that the ingress contain appropiate certificate ( and DNS entry ) using operators on k8s
    #
    # preserve_client_ip is enabled by default for instances
    {
      name                 = "nlb-ext-${local.name}-https"
      backend_protocol     = "TCP"
      backend_port         = 443
      target_type          = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 10
        path                = "/healthz"
        port                = 80
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
      }
    },
  ]

  #  For this blog purposes - our external NLB is only listening for 443 - should you need something else 
  #  you can add it here
  http_tcp_listeners = [
    {
      port               = 443
      protocol           = "TCP"
      target_group_index = 0
    },
  ]

  target_group_tags = { "owner" = "raf" }

  lb_tags = {
    "lb-scope" = "external"
    "lb-type"  = "nlb"
  }

  tags = {
    "owner" = "raf"
  }
}

resource "aws_security_group" "nlb_external" {
  count = var.create_nlb_external ? 1 : 0

  description = "Security group allowing access to external ingress"
  vpc_id      = module.vpc.vpc_id
  name        = local.external_sg_name

  ingress {
    cidr_blocks = [var.vpc_cidr_block]
    description = "allow vpc traffic"
    from_port   = 0
    to_port     = 0
    protocol    = -1
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow external traffic from specific CIDRs"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "owner" = "raf"
    "Name"  = local.external_sg_name
  }
}

resource "aws_security_group" "nlb_internal" {
  count = var.create_nlb_internal ? 1 : 0

  description = "Security group allowing access to internal ingress"
  vpc_id      = module.vpc.vpc_id
  name        = local.internal_sg_name

  ingress {
    cidr_blocks = [var.vpc_cidr_block]
    description = "allow vpc traffic"
    from_port   = 0
    to_port     = 0
    protocol    = -1
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow traffic from specific CIDRs"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "owner" = "raf"
    "Name"  = local.internal_sg_name
  }
}

module "nlb_internal" {
  source    = "terraform-aws-modules/alb/aws"
  version   = "8.2.1"

  name = "nlb-int-${local.name}"

  load_balancer_type = "network"
  internal           = true
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.private_subnets

  enable_cross_zone_load_balancing = true
  enable_deletion_protection       = false

  target_groups = [
    # With the following target group we are using SSL passthrough and we will make sure 
    # that the ingress contain the appropriate certificate ( and DNS entry ) using operators on k8s
    #
    # preserve_client_ip is enabled by default for instances
    {
      name                 = "nlb-int-${local.name}-https"
      backend_protocol     = "TCP"
      backend_port         = 443
      target_type          = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/healthz"
        port                = 80
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
      }
    },
  ]

  #  internal listeners
  http_tcp_listeners = [
    {
      port               = 443
      protocol           = "TCP"
      target_group_index = 0
    },
  ]

  target_group_tags = { "owner" = "raf" }

  lb_tags = {
    "lb-scope" = "internal"
    "lb-type"  = "nlb"
  }

  tags = {
    "owner" = "raf"
  }
}