# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "terraform-drills-lambda-secrets-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "Lambda Secrets Role"
    Environment = "Dev"
    Project     = "Terraform Drills"
  }
}

# IAM Policy for Secrets Manager access
resource "aws_iam_policy" "secrets_policy" {
  name = "terraform-drills-lambda-secrets-policy"

  description = "Policy for Lambda to access Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name        = "Lambda Secrets Policy"
    Environment = "Dev"
    Project     = "Terraform Drills"
  }
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "lambda_secrets" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.secrets_policy.arn
}
 