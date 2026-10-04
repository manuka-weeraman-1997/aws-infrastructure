# Ansible: post-provisioning configuration

## What it does
Terraform creates the EC2 instance (compute, network, IAM); Ansible takes it from "a blank box" to "a running application". It installs packages, deploys the application artifact, templates environment-specific configuration, and makes sure the service is enabled and running.

## Why Terraform doesn't do this
Terraform is declarative infrastructure state — it's a poor fit for "install these packages, start this process, restart it if config changed". Ansible is built for exactly that: ordered tasks, idempotent by design (running it twice produces the same end state, it doesn't re-do work that's already done), and it models *configuration* rather than *infrastructure*.

## How it behaves
- **Idempotency**: every task checks current state before acting — `package` won't reinstall an already-installed package, `template` only triggers a restart (via `notify`/`handlers`) when the rendered file actually changes.
- **Handlers**: the `restart app` handler only fires once, at the end of the play, even if multiple tasks notify it — so a run that touches three config files restarts the service once, not three times.
- **Roles**: grouping tasks/templates/handlers into a `roles/app` role keeps the logic reusable across environments (dev/qa/prod) by just changing the inventory and variables, not the playbook itself.

## Why it's needed
Without configuration management, server setup is either manual (slow, inconsistent, undocumented) or baked permanently into a golden image (inflexible — every app config change means rebuilding an AMI). Ansible sits in between: fast to iterate on, but still fully repeatable and auditable as code.
