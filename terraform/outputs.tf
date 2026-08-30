output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for the EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnets
}

output "node_security_group_id" {
  description = "Security group ID used by EKS worker nodes"
  value       = module.eks.node_security_group_id
}

output "ecr_repository_url" {
  description = "ECR repository URL for the Vehicle API"
  value       = aws_ecr_repository.vehicle_api.repository_url
}

output "github_actions_role_arn" {
  description = "IAM role assumed by GitHub Actions using OIDC"
  value       = aws_iam_role.github_actions.arn
}

output "aws_load_balancer_controller_role_arn" {
  description = "IAM role used by AWS Load Balancer Controller"
  value       = aws_iam_role.load_balancer_controller.arn
}