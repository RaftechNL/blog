variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of tags to add to all resources."
}

variable "cluster_name" {
  default     = ""
  description = "Desired name of the cluster (if empty uses nanming standard)"
}

variable "cluster_version" {
  description = "Desired version of the EKS cluster"
}

variable "vpc_id" {
  description = "Target VPC for the cluster"
}

variable "vpc_cidrs" {
  description = "VPC CIDRs"
}

variable "subnets_private" {
  description = "Target private subnets for the cluster"
}

variable "subnets_public" {
  description = "Target public subnets for the cluster"
}

variable "cluster_enabled_log_types" {
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  description = "EKS cluster enabled log types"
}

variable "cluster_endpoint_private_access" {
  type        = bool
  default     = true
  description = "EKS control plane accessible internally"
}

variable "cluster_endpoint_public_access" {
  type        = bool
  default     = true
  description = "EKS control plane accessible externally"
}

variable "cluster_endpoint_public_access_cidrs" {
  default     = ["0.0.0.0/0"]
  description = "EKS control externally allowed CIDRs"
}

variable "workers_role_name" {
  default     = ""
  description = "EKS worker role name"
}

variable "create_internal_nlb" {
  description = "Controls creation of internal nlb"
  type        = bool
  default     = false
}

variable "create_external_alb" {
  description = "Controls creation of external alb"
  type        = bool
  default     = false
}

variable "configuration_nlb" {
  description = "Configuration for AWS Load Balancer"
  default = {
    "ext" = {
      port_ingress = 31443

      port_health = 31254
      path_health = "/healthz"
    }
    "int" = {
      port_ingress = 30443

      port_health = 30254
      path_health = "/healthz"
    }
  }


  type = map(object({
    port_ingress = number
    port_health  = number

    path_health = string
  }))
}
variable "whitelist_external" {
  description = "Security group ingress rules for external loadbalancer"
  default     = {}

  type = map(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "whitelist_internal_vpc" {
  description = "Controls if VPC CIDRs are whitelisted on internal NLB"
  type        = bool
  default     = true
}

variable "whitelist_internal" {
  description = "Security group ingress rules for internal loadbalancer"
  default     = {}

  type = map(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "map_roles" {

  description = "A list of roles to be added into EKS aws-auth config map"

  type = list(object({
    rolearn  = string,
    username = string,
    groups   = list(string),
  }))

  default = []
}

variable "extra_worker_groups" {
  description = "Contains configuration for extra worker groups to be created on top of base ( see https://github.com/terraform-aws-modules/terraform-aws-eks/blob/v17.24.0/locals.tf#L36 for details)"
  default     = []
}

variable "resource_prefix" { 
  default = "demo-io"
}