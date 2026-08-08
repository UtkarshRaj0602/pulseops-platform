output "backend_repository_url" {
  value = module.ecr.backend_repository_url
}

output "frontend_repository_url" {
  value = module.ecr.frontend_repository_url
}

output "worker_repository_url" {
  value = module.ecr.worker_repository_url
}
