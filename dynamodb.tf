# DynamoDB Table
resource "aws_dynamodb_table" "main" {
  name           = "terraform-drills-dynamodb"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "ID"

  attribute {
    name = "ID"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Name        = "Main DynamoDB Table"
    Environment = "Dev"
    Project     = "Terraform Drills"
  }
}