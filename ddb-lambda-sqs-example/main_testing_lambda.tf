locals {
  lambda_code_relative_path = "${path.module}/test_lambda_function"
  files_to_include          = ["test_lambda.py"]
}

data "archive_file" "lambda_code" {
  type             = "zip"
  source_dir       = local.lambda_code_relative_path
  output_path      = "${path.module}/lambda_function_payload.zip"
  output_file_mode = "0666"

  excludes = [for file in fileset(local.lambda_code_relative_path, "**/*") : file if !contains(local.files_to_include, file)]
}

resource "aws_lambda_function" "lambda_function" {
  filename         = data.archive_file.lambda_code.output_path
  function_name    = "debugging_lambda"
  role             = "arn:aws:iam::000000000000:role/lambda-role"
  handler          = "test_lambda.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = data.archive_file.lambda_code.output_base64sha256

  environment {
    variables = {
      ENVIRONMENT = "testing"
    }
  }

  depends_on = [docker_container.localstack_container]
}
