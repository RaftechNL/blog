output "cluster" {
  value = {
    "cluster_id"                         = module.eks.cluster_id,
    "cluster_arn"                        = module.eks.cluster_arn,
    "cluster_certificate_authority_data" = module.eks.cluster_certificate_authority_data,
    "cluster_endpoint"                   = module.eks.cluster_endpoint,
    "cluster_version"                    = module.eks.cluster_version,
    "cluster_security_group_id"          = module.eks.cluster_security_group_id,
    "cluster_iam_role_name"              = module.eks.cluster_iam_role_name,
    "cluster_iam_role_arn"               = module.eks.cluster_iam_role_arn,
    "cluster_oidc_issuer_url"            = module.eks.cluster_oidc_issuer_url,
    "oidc_provider_arn"                  = module.eks.oidc_provider_arn,
    "worker_iam_role_name"               = module.eks.worker_iam_role_name,
    "worker_iam_role_arn"                = module.eks.worker_iam_role_arn,
  }
}

output "cluster_id" {
  description = "The name/id of the EKS cluster. Will block on cluster creation until the cluster is really ready."
  value       = module.eks.cluster_id
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster."
  value       = module.eks.cluster_arn
}

output "cluster_certificate_authority_data" {
  description = "Nested attribute containing certificate-authority-data for your cluster. This is the base64 encoded certificate data required to communicate with your cluster."
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_endpoint" {
  description = "The endpoint for your EKS Kubernetes API."
  value       = module.eks.cluster_endpoint
}

output "cluster_version" {
  description = "The Kubernetes server version for the EKS cluster."
  value       = module.eks.cluster_version
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster. On 1.14 or later, this is the 'Additional security groups' in the EKS console."
  value       = module.eks.cluster_security_group_id
}

output "cluster_iam_role_name" {
  description = "IAM role name of the EKS cluster."
  value       = module.eks.cluster_iam_role_name
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster."
  value       = module.eks.cluster_iam_role_arn
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = module.eks.cluster_oidc_issuer_url
}


output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if `enable_irsa = true`."
  value       = module.eks.oidc_provider_arn
}

output "worker_iam_role_name" {
  description = "default IAM role name for EKS worker groups"
  value       = module.eks.worker_iam_role_name
}

output "worker_iam_role_arn" {
  description = "default IAM role ARN for EKS worker groups"
  value       = module.eks.worker_iam_role_arn
}