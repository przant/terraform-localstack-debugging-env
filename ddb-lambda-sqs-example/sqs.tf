resource "aws_sqs_queue" "sqs_001_sqs_queue" {
  name       = "sqs_001.fifo"
  fifo_queue = true

  depends_on = [docker_container.localstack_container]
}

resource "aws_sqs_queue" "sqs_002_sqs_queue" {
  name       = "sqs_002.fifo"
  fifo_queue = true

  depends_on = [docker_container.localstack_container]
}