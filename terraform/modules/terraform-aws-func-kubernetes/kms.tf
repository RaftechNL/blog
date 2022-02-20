resource "aws_kms_key" "eks" {
  description             = "EKS cluster key for secret encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = merge(
    {},
    local.tags_app_module
  )
}

resource "aws_kms_alias" "eks" {
  name          = "alias/eks-${local.cluster_name}"
  target_key_id = aws_kms_key.eks.key_id
}