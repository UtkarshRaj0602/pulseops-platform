resource "kubernetes_manifest" "secret_store" {

  manifest = {
    apiVersion = "external-secrets.io/v1"

    kind = "SecretStore"

    metadata = {
      name      = var.secret_store_name
      namespace = var.namespace
    }

    spec = {

      provider = {

        aws = {

          service = "SecretsManager"

          region = var.aws_region

          auth = {

            jwt = {

              serviceAccountRef = {
                name = "external-secrets"
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

    kind = "ExternalSecret"

    metadata = {

      name = "backend-secret"

      namespace = var.namespace

    }

    spec = {

      refreshInterval = "1h"

      secretStoreRef = {

        name = var.secret_store_name

        kind = "SecretStore"

      }

      target = {

        name = "backend-secret"

        creationPolicy = "Owner"

      }

      data = [

        {
          secretKey = "username"

          remoteRef = {

            key = var.database_secret_name

            property = "username"

          }

        },

        {
          secretKey = "password"

          remoteRef = {

            key = var.database_secret_name

            property = "password"

          }

        }

      ]

    }

  }

}
