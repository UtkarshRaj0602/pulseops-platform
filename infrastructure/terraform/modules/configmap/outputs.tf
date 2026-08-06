output "backend_configmap_name" {
  value = kubernetes_config_map_v1.backend.metadata[0].name
}

output "worker_configmap_name" {
  value = kubernetes_config_map_v1.worker.metadata[0].name
}
