locals {
   lambda_code_relative_path = "${path.module}/relative-or-absolute-path-to-the-source-code"
  files_to_include = [
    # the files to include for debugging this lambda
    # The list of files have to include only the implementation code
    # not the setup.py, and so on
  ]
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
  function_name    = "crx_ws_notification"
  role             = "arn:aws:iam::000000000000:role/lambda-role"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = data.archive_file.lambda_code.output_base64sha256

  environment {
    variables = {
      ENVIRONMENT         = "testing"
      SECRET_ENV_VAR_NAME = aws_secretsmanager_secret.database_secret.name
    }
  }

  depends_on = [docker_container.localstack_container]
}
