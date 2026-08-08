resource "kubernetes_namespace" "this" {

  metadata {

    name = var.namespace

    labels = {

      app = var.project_name

      environment = var.environment

    }

  }

}
