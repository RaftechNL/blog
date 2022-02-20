locals {
  resource_prefix = var.resource_prefix
  
  tags_app_module = merge(
    var.tags,         # Tags coming from calling TF
    local.tags_module # Tags locally added
  )

  tags_module = {
    app-name        = local.cluster_name
    app-github-repo = "https://github.com/Raf-Tech/medium-building-robust-container-platform"
    app-role        = "kubernetes"
    app-owner       = "devops"
    app-part-of     = "platform"
    app-team        = "devops"

    tf-module-func = "terraform-aws-func-kubernetes"
  }

}

data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}



