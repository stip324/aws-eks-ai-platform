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

output "vehicle_api_role_arn" {
  description = "IAM role used by the vehicle-api workload"
  value       = aws_iam_role.vehicle_api.arn
}

output "vehicle_api_secret_arn" {
  description = "Secrets Manager secret used by vehicle-api"
  value       = aws_secretsmanager_secret.vehicle_api.arn
}

output "ssm_admin_instance_id" {
  description = "EC2 instance used for private EKS administration through SSM"
  value       = aws_instance.ssm_admin.id
}

output "ssm_admin_role_arn" {
  description = "IAM role used by the SSM EKS admin host"
  value       = aws_iam_role.ssm_admin.arn
}