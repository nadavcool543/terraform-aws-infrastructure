# DynamoDB Table
resource "aws_dynamodb_table" "main" {
  name           = "${var.project_name}-dynamodb"
  billing_mode   = "PROVISIONED"
  read_capacity  = var.dynamodb_read_capacity
  write_capacity = var.dynamodb_write_capacity
  hash_key       = "ID"

  attribute {
    name = "ID"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = merge(
    var.common_tags,
    {
      Name = "Main DynamoDB Table"
    }
  )
}