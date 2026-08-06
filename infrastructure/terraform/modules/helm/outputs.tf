output "aws_load_balancer_controller_release" {
  description = "AWS Load Balancer Controller Helm Release"

  value = helm_release.aws_load_balancer_controller.name
}

output "metrics_server_release" {
  description = "Metrics Server Helm Release"

  value = helm_release.metrics_server.name
}

output "external_secrets_release" {
  description = "External Secrets Helm Release"

  value = helm_release.external_secrets.name
}

output "monitoring_release" {
  description = "kube-prometheus-stack Helm Release"

  value = helm_release.kube_prometheus_stack.name
}

output "aws_load_balancer_controller_namespace" {

  value = helm_release.aws_load_balancer_controller.namespace

}

output "metrics_server_namespace" {

  value = helm_release.metrics_server.namespace

}

output "external_secrets_namespace" {

  value = helm_release.external_secrets.namespace

}

output "monitoring_namespace" {

  value = helm_release.kube_prometheus_stack.namespace

}
