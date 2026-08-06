My recommendation

Don't build monitoring twice.

Instead:

## Local Development

Frontend
FastAPI
Worker

↓

Basic testing

---

AWS Deployment

↓

Terraform

↓

Amazon EKS

↓

Deploy Application

↓

Install Prometheus

↓

Install Grafana

↓

Configure ServiceMonitor

↓

Configure PrometheusRule

↓

Verify Metrics
Monitoring Stack

Inside your EKS cluster you'll have something like:

Amazon EKS
│
├── ingress-nginx
│
├── kube-system
│
├── monitoring
│ │
│ ├── Prometheus
│ ├── Grafana
│ ├── Alertmanager
│ ├── Node Exporter
│ ├── kube-state-metrics
│ └── ServiceMonitors
│
└── pulseops
│
├── frontend
├── api
└── worker
I would install

Using Helm:

kube-prometheus-stack

That gives you:

Prometheus
Grafana
Alertmanager
Node Exporter
kube-state-metrics
CRDs
ServiceMonitor
PrometheusRule

All in one installation.

It's also the industry-standard approach.

Metrics you'll collect
Kubernetes
Node CPU
Node Memory
Pod CPU
Pod Memory
Pod Restarts
Deployment Status
HPA Metrics
FastAPI
HTTP Requests
Response Time
Error Rate (4xx/5xx)
Request Duration
Active Requests
Worker

Custom metrics:

jobs_processed_total

jobs_failed_total

processing_duration_seconds

sqs_messages_processed

worker_uptime
PostgreSQL
Connections
Query latency
Storage
CPU
Memory
Redis
Cache hits
Cache misses
Memory usage
Connected clients
SQS

CloudWatch already provides:

Approximate Messages Visible
Messages In Flight
Empty Receives
Oldest Message Age

You can visualize those in Grafana using CloudWatch as a data source if you choose, or simply rely on CloudWatch dashboards for queue metrics.

Terraform

Your Terraform should provision only the AWS infrastructure:

VPC

IAM

Security Groups

Amazon EKS

Amazon RDS

Amazon ElastiCache

Amazon SQS

Amazon ECR

Secrets Manager
Kubernetes

After Terraform completes:

terraform apply

↓

aws eks update-kubeconfig

↓

kubectl apply

↓

Helm Install kube-prometheus-stack

↓

Deploy PulseOps
GitHub Actions

Pipeline becomes:

Push

↓

Build

↓

Test

↓

Docker Build

↓

Push to Amazon ECR

↓

Terraform Apply

↓

Deploy to EKS

↓

Install/Upgrade Helm Charts

↓

Smoke Test
