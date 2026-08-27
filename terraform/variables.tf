variable "aws_region" {
  description = "AWS region used for the EKS platform"
  type        = string
  default     = "eu-west-2"
}

variable "project_name" {
  description = "Project name used for resource identification"
  type        = string
  default     = "eks-interview-demo"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "cluster_version" {
  description = "Kubernetes version for EKS"
  type        = string
  default     = "1.36"
}

variable "node_instance_types" {
  description = "EC2 instance types for the managed node group"
  type        = list(string)
  default     = ["t3.small"]
}

variable "node_min_size" {
  description = "Minimum size of the managed node group"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum size of the managed node group"
  type        = number
  default     = 2
}

variable "node_desired_size" {
  description = "Desired size of the managed node group"
  type        = number
  default     = 1
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDR blocks allowed to access the public EKS API endpoint"
  type        = list(string)
}