# AWS Infrastructure

A collection of infrastructure-as-code examples demonstrating core AWS platform engineering patterns: elastic compute, configuration management, managed streaming, and traffic distribution.

Each component is self-contained with its own Terraform/Ansible and a README explaining *why* it exists and how it behaves in production.

| Component | What it is | Why it's here |
|---|---|---|
| [`auto-scaling-group/`](auto-scaling-group) | EC2 Auto Scaling Group + Launch Template | Elastic compute capacity that reacts to load and instance failure |
| [`ansible/`](ansible) | Ansible role for post-provisioning configuration | Idempotent, repeatable server configuration after Terraform creates the instance |
| [`msk/`](msk) | Amazon MSK (Managed Streaming for Kafka) cluster | Durable, ordered event streaming between services |
| [`load-balancer/`](load-balancer) | Application Load Balancer | Distributes traffic across healthy instances, terminates TLS |
| [`lambda/`](lambda) | Scheduled Lambda function | Event-driven compute for periodic tasks, no always-on server |

See [`aws-log-backup`](https://github.com/manuka-weeraman-1997/aws-log-backup) for a Lambda used in a real pipeline (EC2 → EFS → S3).

See [`azure-infrastructure`](https://github.com/manuka-weeraman-1997/azure-infrastructure) for the same patterns implemented on Azure.

Author: Manuka Weeraman — Platform Engineer
