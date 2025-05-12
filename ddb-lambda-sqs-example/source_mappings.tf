resource "aws_lambda_event_source_mapping" "sqs_001_to_lambda_function_001" {
  event_source_arn = aws_sqs_queue.sqs_001_sqs_queue.arn
  function_name    = aws_lambda_function.lambda_function_001.function_name

  enabled = true

  depends_on = [
    aws_sqs_queue.sqs_001_sqs_queue,
    aws_lambda_function.lambda_function_001
  ]
}