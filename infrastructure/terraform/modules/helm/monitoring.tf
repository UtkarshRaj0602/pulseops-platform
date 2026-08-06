resource "helm_release" "kube_prometheus_stack" {

  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true

  version = "75.15.1"

  wait    = true
  timeout = 900

}
