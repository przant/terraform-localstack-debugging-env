resource "aws_secretsmanager_secret" "oracle_secret" {
  name = "localstack_test_credentials"

  tags = {
    Environment = "dthe env variable if necessary"
  }

  depends_on = [docker_container.localstack]
}

resource "aws_secretsmanager_secret_version" "oracle_secret_version" {
  secret_id = aws_secretsmanager_secret.oracle_secret.id

  secret_string = jsonencode({
    host     = "the host to use"
    password = "the password"
    port     = "the port"
    service  = "the service name"
    username = "the username"
  })

  depends_on = [docker_container.localstack]
}