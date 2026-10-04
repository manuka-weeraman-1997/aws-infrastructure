# Auto Scaling Group (ASG)

## What it does
An ASG keeps a fleet of EC2 instances running between a `min` and `max` size, launched from a shared `aws_launch_template`. It doesn't run the application itself — it guarantees *how many* healthy instances of it exist at any time.

## Behaviour
- **Health checks** (`health_check_type = "ELB"`): the ASG asks the load balancer's target group whether each instance is healthy, not just whether the EC2 instance is "running". An instance that's up but failing app health checks gets terminated and replaced.
- **Target tracking scaling**: `aws_autoscaling_policy` watches average CPU across the group and adds/removes instances to hold it near 60%. This reacts to real load instead of needing manual capacity planning.
- **Instance refresh**: when the launch template changes (new AMI, new instance type), the ASG replaces instances a few at a time (`min_healthy_percentage = 90`) instead of all at once, so capacity never drops to zero during a rollout.
- **Lifecycle**: new instances boot from the launch template's `user_data`, which is where bootstrap steps (e.g. registering with a config management tool, pulling the latest app version) run before the instance starts receiving traffic.

## Why it's needed
Running fixed-size fleets means either over-provisioning for peak load (wasted cost) or under-provisioning (outages during spikes). An ASG ties capacity to actual demand and automatically self-heals when instances fail, which is the baseline pattern underneath almost every stateless service tier.
