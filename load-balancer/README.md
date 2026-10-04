# Application Load Balancer (ALB)

## What it does
Sits in front of the Auto Scaling Group and is the single stable entry point for traffic — instances come and go as the ASG scales, but the ALB's DNS name never changes.

## Behaviour
- **Health-checked routing**: the ALB only forwards traffic to targets passing `/health` (3 consecutive successes to go in, 3 failures to go out) — a newly launched instance that hasn't finished booting the app never receives real traffic, and a failing instance is removed automatically.
- **TLS termination**: HTTPS is terminated at the ALB (`aws_lb_listener.https`), so certificate management lives in one place instead of on every instance, and backend traffic can run plain HTTP on the private network.
- **Protocol upgrade**: the port-80 listener's only job is a 301 redirect to HTTPS, so nothing is ever served unencrypted even if a client requests plain HTTP.
- **Layer 7 routing**: because it understands HTTP (unlike a Layer 4/Network Load Balancer), it can route on host/path, inspect headers, and integrate with a WAF.

## Why it's needed
Without a load balancer, clients would need to know about every individual instance's IP — which breaks the moment the ASG scales in/out or replaces a failed instance. The ALB decouples "how many instances exist" from "how clients reach the service", and is the layer that actually keeps a scaling event invisible to users.
