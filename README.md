# AWS Infrastructure

A collection of infrastructure-as-code examples demonstrating core AWS platform engineering patterns: elastic compute, configuration management, managed streaming, and traffic distribution.

Each component is self-contained with its own Terraform/Ansible and a README explaining *why* it exists and how it behaves in production.

| Component | What it is | Why it's here |
|---|---|---|
| [`auto-scaling-group/`](auto-scaling-group) | EC2 Auto Scaling Group + Launch Template | Elastic compute capacity that reacts to load and instance failure |
| [`ansible/`](ansible) | Ansible role for post-provisioning configuration | Idempotent, repeatable server configuration after Terraform creates the instance |
| [`msk/`](msk) | Amazon MSK (Managed Streaming for Kafka) cluster | Durable, ordered event streaming between services |
| [`load-balancer/`](load-balancer) | Application Load Balancer | Distributes traffic across healthy instances, terminates TLS |

See [`azure-infrastructure`](https://github.com/manuka-weeraman-1997/azure-infrastructure) for the same patterns implemented on Azure.

Author: Manuka Weeraman — Platform Engineer
