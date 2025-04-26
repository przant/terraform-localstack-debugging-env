resource "docker_network" "localstack-network" {
  name            = "localstack-lan"
  attachable      = true
  check_duplicate = "true"
  driver          = "bridge"
}

resource "docker_volume" "localstack-volume" {
  name   = "localstack-vol"
  driver = "local"
}

resource "docker_container" "localstack" {
  name  = "ws-testing-localstack"
  image = "localstack/localstack:stable"

  env = [
    "SERVICES=iam,lambda,sqs,secretsmanager",
    "DOCKER_HOST=unix:///var/run/docker.sock",
    "AWS_DEFAULT_REGION=us-west-2",
    "GATEWAY_LISTEN=4566",
    "PERSISTENCE=1",
    "DATA_DIR=/var/lib/localstack",
    "LAMBDA_DOCKER_NETWORK=localstack-lan",
    "LAMBDA_DOCKER_FLAGS=-v /var/run/docker.sock:/var/run/docker.sock -p 19891:19891",
    "ENVIRONMENT=dev",
    "DEBUG=1",
    "ENVIRONMENT=dev",
    "SECRET_ENV_VAR_NAME=localstack_oracle_dev_credentials"
  ]

  network_mode = docker_network.localstack-network.name

  remove_volumes = true

  restart = "on-failure"

  privileged = true

  ports {
    internal = 4566
    external = 4566
  }

  ports {
    internal = 4571
    external = 4571
  }

  # Docker socket mount
  volumes {
    container_path = "/var/run/docker.sock"
    host_path      = "/var/run/docker.sock"
  }

  # Localstack persistence volume mount
  volumes {
    container_path = "/var/lib/localstack"
    volume_name    = docker_volume.localstack-volume.name
  }

  depends_on = [
    docker_network.localstack-network,
    docker_volume.localstack-volume
  ]
}

output "localstack" {
  value = docker_container.localstack.name
}