# Worker

The worker asynchronously processes jobs from Amazon SQS.

```text
SQS
 -> Receive message
 -> Process input
 -> Update PostgreSQL
 -> Cache result in Redis
 -> Delete message
```

For the demonstrated application logic, submitted text is converted to uppercase.

Example:

```text
hello pulseops -> HELLO PULSEOPS
```

The worker uses PostgreSQL, Redis and SQS configuration supplied by Kubernetes.
