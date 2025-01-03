# Create a secret in AWS Secrets Manager
resource "aws_secretsmanager_secret" "demo" {
  name = "demo-nginx-2"
  force_overwrite_replica_secret = true
  recovery_window_in_days = 0  # Immediate deletion
  tags = {
    Environment = "Dev"
    Project     = "Terraform Drills"
  }
}

resource "aws_secretsmanager_secret_version" "demo" {
  secret_id = aws_secretsmanager_secret.demo.id
  secret_string = jsonencode({
    DEMO_USERNAME = "admin"
    DEMO_PASSWORD = "supersecret123!"
  })
} 