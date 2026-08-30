resource "aws_secretsmanager_secret" "vehicle_api" {
  name        = "${var.project_name}/vehicle-api"
  description = "Secrets used by the vehicle-api workload"

  tags = {
    Name = "${var.project_name}-vehicle-api"
  }
}


data "aws_iam_policy_document" "vehicle_api_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "pods.eks.amazonaws.com"
      ]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes-namespace"

      values = [
        "vehicle-platform"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes-service-account"

      values = [
        "vehicle-api"
      ]
    }
  }
}


resource "aws_iam_role" "vehicle_api" {
  name = "${var.project_name}-vehicle-api"

  assume_role_policy = data.aws_iam_policy_document.vehicle_api_assume_role.json

  tags = {
    Name = "${var.project_name}-vehicle-api"
  }
}


data "aws_iam_policy_document" "vehicle_api_secrets" {
  statement {
    sid = "ReadVehicleApiSecret"

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]

    resources = [
      aws_secretsmanager_secret.vehicle_api.arn
    ]
  }
}


resource "aws_iam_policy" "vehicle_api_secrets" {
  name = "${var.project_name}-vehicle-api-secrets"

  policy = data.aws_iam_policy_document.vehicle_api_secrets.json
}


resource "aws_iam_role_policy_attachment" "vehicle_api_secrets" {
  role       = aws_iam_role.vehicle_api.name
  policy_arn = aws_iam_policy.vehicle_api_secrets.arn
}


resource "aws_eks_pod_identity_association" "vehicle_api" {
  cluster_name = module.eks.cluster_name

  namespace       = "vehicle-platform"
  service_account = "vehicle-api"

  role_arn = aws_iam_role.vehicle_api.arn
}