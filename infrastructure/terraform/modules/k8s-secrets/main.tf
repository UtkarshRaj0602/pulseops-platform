resource "kubernetes_manifest" "secret_store" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ClusterSecretStore"

    metadata = {
      name = var.secret_store_name
      # namespace = var.namespace
    }

    spec = {
      provider = {
        aws = {
          service = "SecretsManager"
          region  = var.aws_region

          auth = {
            jwt = {
              serviceAccountRef = {
                name      = "external-secrets"
                namespace = "external-secrets"
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_manifest" "database_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"

    metadata = {
      name      = "backend-secret"
      namespace = var.namespace
    }

    spec = {
      refreshInterval = "1h"

      secretStoreRef = {
        name = var.secret_store_name
        kind = "ClusterSecretStore"
      }

      target = {
        name           = "backend-secret"
        creationPolicy = "Owner"
      }

      data = [
        {
          secretKey = "DB_USERNAME"

          remoteRef = {
            key      = var.database_secret_name
            property = "username"
          }
        },
        {
          secretKey = "DB_PASSWORD"

          remoteRef = {
            key      = var.database_secret_name
            property = "password"
          }
        }
      ]
    }
  }
}
