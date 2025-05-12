resource "aws_secretsmanager_secret" "database_secret" {
  name = "localstack_test_credentials"

  tags = {
    Environment = "testing"
  }

  depends_on = [docker_container.localstack_container]
}

resource "aws_secretsmanager_secret_version" "database_credentials_secret_version" {
  secret_id = aws_secretsmanager_secret.database_secret.id

  secret_string = jsonencode({
    host     = "the_host_to_use"
    password = "the_password"
    port     = "the_port"
    service  = "the_service_name"
    username = "the_username"
  })

  depends_on = [docker_container.localstack_container]
}