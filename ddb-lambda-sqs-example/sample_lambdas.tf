data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/dummy_lambda_code/lambda_function.py"
  output_path = "${path.module}/hello_lambda_payload.zip"
}

resource "aws_lambda_function" "lambda_function_001" {
  function_name = "aws_lambda_function_001"
  runtime       = "python3.12"
  handler       = "lambda_function.lambda_handler"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  role = "arn:aws:iam::123456789012:role/DummyLambdaRole"

  depends_on = [docker_container.localstack_container]
}

resource "aws_lambda_function" "lambda_function_002" {
  function_name = "aws_lambda_function_002"
  runtime       = "python3.12"
  handler       = "lambda_function.lambda_handler"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  role = "arn:aws:iam::123456789012:role/DummyLambdaRole"

  depends_on = [docker_container.localstack_container]
}