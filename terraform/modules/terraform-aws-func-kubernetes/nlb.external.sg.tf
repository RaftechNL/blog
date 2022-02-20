resource "aws_security_group" "nlb_external" {
  description = "Security group allowing external access to NLB"
  vpc_id      = var.vpc_id
  name        = "nlb-ext-${local.cluster_name}"

  dynamic "ingress" {
    for_each = var.whitelist_external
    content {
      description = lookup(ingress.value, "description", null)
      from_port   = lookup(ingress.value, "from_port", null)
      to_port     = lookup(ingress.value, "to_port", null)
      protocol    = lookup(ingress.value, "protocol", null)
      cidr_blocks = lookup(ingress.value, "cidr_blocks", null)
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = merge(
    local.tags_app_module,
    {
      "sg-scope" = "ext"
    }
  )

}