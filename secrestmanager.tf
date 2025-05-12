resource "aws_secretsmanager_secret" "database_secret" {
  name = "localstack_test_credentials"

  tags = {
    Environment = "testing"
  }

  depends_on = [docker_container.localstack]
}

resource "aws_secretsmanager_secret_version" "database_credentials_secret_version" {
  secret_id = aws_secretsmanager_secret.database_secret.id

  secret_string = jsonencode({
    host     = "the host to use"
    password = "the password"
    port     = "the port"
    service  = "the service name"
    username = "the username"
  })

  depends_on = [docker_container.localstack]
}