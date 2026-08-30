data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

data "aws_iam_policy_document" "ssm_admin_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ssm_admin" {
  name               = "${var.project_name}-ssm-admin"
  assume_role_policy = data.aws_iam_policy_document.ssm_admin_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ssm_admin_core" {
  role       = aws_iam_role.ssm_admin.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_admin" {
  name = "${var.project_name}-ssm-admin"
  role = aws_iam_role.ssm_admin.name
}

resource "aws_security_group" "ssm_admin" {
  name        = "${var.project_name}-ssm-admin"
  description = "Security group for private SSM EKS administration host"
  vpc_id      = module.vpc.vpc_id

  # No inbound rules are required because access is through SSM.

  # The SSM admin host is in a private subnet with no public IP.
  # Outbound HTTPS is required for SSM connectivity, AWS APIs,
  # package updates and kubectl installation through the NAT Gateway.
  # Inbound access remains disabled.
  #trivy:ignore:AVD-AWS-0104
  egress {
    description = "HTTPS outbound via NAT Gateway"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ssm-admin"
  }
}

resource "aws_instance" "ssm_admin" {
  ami                    = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type          = "t3.micro"
  subnet_id              = module.vpc.private_subnets[0]
  vpc_security_group_ids = [aws_security_group.ssm_admin.id]

  iam_instance_profile        = aws_iam_instance_profile.ssm_admin.name
  associate_public_ip_address = false

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = 8
  }

  user_data = <<-EOF
    #!/bin/bash
    set -e

    dnf update -y
    dnf install -y curl unzip

    curl -LO "https://dl.k8s.io/release/v1.36.0/bin/linux/amd64/kubectl"
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm -f kubectl

    aws eks update-kubeconfig \
      --region ${var.aws_region} \
      --name ${module.eks.cluster_name}
  EOF

  tags = {
    Name = "${var.project_name}-ssm-admin"
  }

  depends_on = [
    module.eks,
    aws_iam_role_policy_attachment.ssm_admin_core
  ]
}

resource "aws_eks_access_entry" "ssm_admin" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_iam_role.ssm_admin.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "ssm_admin" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_iam_role.ssm_admin.arn

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [
    aws_eks_access_entry.ssm_admin
  ]
}