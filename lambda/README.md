# Lambda: scheduled event-driven task

## What it does
Runs a small, stateless task on a fixed schedule (`rate(15 minutes)`, via EventBridge) without a server sitting idle between runs.

## Behaviour
- **Least-privilege execution role**: the function's IAM role only has `AWSLambdaBasicExecutionRole` attached (permission to write its own CloudWatch Logs) — any additional access (reading from S3, writing to a queue, etc.) has to be added explicitly, rather than the function inheriting broad account permissions.
- **EventBridge, not a loop**: the function doesn't poll for anything or run continuously — EventBridge invokes it on schedule, and nothing runs (or is billed) in between invocations.
- **Explicit permission for the trigger**: `aws_lambda_permission` is what actually allows EventBridge to invoke the function — without it, the rule and target can exist but the invocation is silently denied.
- **Timeout and memory are both capped** (`timeout = 30`, `memory_size = 256`): Lambda bills by execution time × memory, and a hung function fails fast instead of running (and billing) indefinitely.

## Why it's needed
Not every job needs a dedicated, always-running server — a short, periodic task (cleanup, a sync job, a scheduled check) that spends most of its time idle is both cheaper and operationally simpler as an event-driven function than as another EC2 instance or container to patch and monitor around the clock.

See [`aws-log-backup`](https://github.com/manuka-weeraman-1997/aws-log-backup)'s `lambda-efs-to-s3-sync` for this same pattern doing real work (syncing log files from EFS to S3).
