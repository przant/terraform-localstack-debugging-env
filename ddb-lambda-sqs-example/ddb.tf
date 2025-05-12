resource "aws_dynamodb_table" "testing_ddb_table" {
  name           = "testing-ddb-table"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1

  hash_key  = "group_id"
  range_key = "resource_type"

  attribute {
    name = "group_id"
    type = "S"
  }

  attribute {
    name = "resource_type"
    type = "S"
  }

  tags = {
    Env = "testing"
  }

  depends_on = [docker_container.localstack_container]
}

resource "aws_dynamodb_table_item" "sqs_table_item_001" {
  table_name = aws_dynamodb_table.testing_ddb_table.name
  hash_key   = aws_dynamodb_table.testing_ddb_table.hash_key
  range_key  = aws_dynamodb_table.testing_ddb_table.range_key

  item = jsonencode({
    group_id      = { S = "001" }
    resource_type = { S = "SQS_QUEUE" }
    resource_name = { S = "sqs_001.fifo" }
  })
}

resource "aws_dynamodb_table_item" "lambda_table_item_001" {
  table_name = aws_dynamodb_table.testing_ddb_table.name
  hash_key   = aws_dynamodb_table.testing_ddb_table.hash_key
  range_key  = aws_dynamodb_table.testing_ddb_table.range_key

  item = jsonencode({
    group_id      = { S = "001" }
    resource_type = { S = "AWS_LAMBDA_FUNCTION" }
    resource_name = { S = "aws_lambda_function_001" }
  })
}

resource "aws_dynamodb_table_item" "sqs_table_item_002" {
  table_name = aws_dynamodb_table.testing_ddb_table.name
  hash_key   = aws_dynamodb_table.testing_ddb_table.hash_key
  range_key  = aws_dynamodb_table.testing_ddb_table.range_key

  item = jsonencode({
    group_id      = { S = "002" }
    resource_type = { S = "SQS_QUEUE" }
    resource_name = { S = "sqs_002.fifo" }
  })
}

resource "aws_dynamodb_table_item" "lambda_table_item_002" {
  table_name = aws_dynamodb_table.testing_ddb_table.name
  hash_key   = aws_dynamodb_table.testing_ddb_table.hash_key
  range_key  = aws_dynamodb_table.testing_ddb_table.range_key

  item = jsonencode({
    group_id      = { S = "002" }
    resource_type = { S = "AWS_LAMBDA_FUNCTION" }
    resource_name = { S = "aws_lambda_function_002" }
  })
}