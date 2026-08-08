resource "kubernetes_config_map_v1" "backend" {

  metadata {
    name      = "backend-config"
    namespace = var.namespace

    labels = {
      "app.kubernetes.io/name"       = "backend"
      "app.kubernetes.io/component"  = "api"
      "app.kubernetes.io/part-of"    = "pulseops-platform"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  data = {
    APP_ENV    = var.environment
    AWS_REGION = var.aws_region

    DB_HOST = var.db_host
    DB_PORT = tostring(var.db_port)
    DB_NAME = var.db_name

    REDIS_HOST = var.redis_host
    REDIS_PORT = tostring(var.redis_port)

    SQS_QUEUE_NAME = var.queue_name

    SQS_QUEUE_URL = var.queue_url

    LOG_LEVEL = var.log_level
  }
}

resource "kubernetes_config_map_v1" "worker" {

  metadata {
    name      = "worker-config"
    namespace = var.namespace

    labels = {
      "app.kubernetes.io/name"       = "worker"
      "app.kubernetes.io/component"  = "worker"
      "app.kubernetes.io/part-of"    = "pulseops-platform"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  data = {
    APP_ENV    = var.environment
    AWS_REGION = var.aws_region

    DB_HOST = var.db_host
    DB_PORT = tostring(var.db_port)
    DB_NAME = var.db_name

    REDIS_HOST = var.redis_host
    REDIS_PORT = tostring(var.redis_port)

    SQS_QUEUE_NAME = var.queue_name

    SQS_QUEUE_URL = var.queue_url

    POLL_INTERVAL = tostring(var.worker_poll_interval)

    LOG_LEVEL = var.log_level
  }
}
