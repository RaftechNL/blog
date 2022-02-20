resource "random_string" "nlb_external" {
  length  = 4
  special = false
  lower   = true
  keepers = {
    # Generate a new pet name each time we reconfigure ALB
    ingress_configuration_hash = sha1(jsonencode(var.configuration_nlb["ext"]))
  }
}

module "nlb_external" {

  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "nlb-ext-${local.cluster_name}"


  load_balancer_type = "network"
  internal           = false
  vpc_id             = var.vpc_id
  subnets            = var.subnets_public

  enable_cross_zone_load_balancing = true
  enable_deletion_protection       = false

  target_groups = [
    # With the following target group we are using SSL passthrough and we will make sure 
    # that the ingress contain appropiate certificate ( and DNS entry ) using operators on k8s
    #
    # preserve_client_ip is enabled by default for instances
    {
      name                 = "nlb-ext-${local.cluster_name}-https-${random_string.nlb_external.id}"
      backend_protocol     = "TCP"
      backend_port         = var.configuration_nlb["ext"].port_ingress
      target_type          = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 30
        path                = var.configuration_nlb["ext"].path_health
        port                = var.configuration_nlb["ext"].port_health
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
      }

    },
  ]

  #  External listeners
  http_tcp_listeners = [
    {
      port               = 443
      protocol           = "TCP"
      target_group_index = 0
    },
  ]

  target_group_tags = merge(
    {},
    local.tags_app_module
  )

  lb_tags = merge(
    {
      "lb-scope" = "ext"
      "lb-type"  = "nlb"
    },
    local.tags_app_module
  )

  tags = merge(
    {
      tf-module     = "terraform-aws-modules/alb/aws"
      tf-module-ver = "6.0"
    },
    local.tags_app_module
  )
}


