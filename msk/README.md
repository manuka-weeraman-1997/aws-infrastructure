# Amazon MSK (Managed Streaming for Kafka)

## What it does
MSK is a managed Kafka cluster — brokers, storage, and patching are handled by AWS, while the cluster still speaks the standard Kafka protocol so existing producers/consumers/tooling work unmodified.

## Behaviour
- **Replication** (`default.replication.factor=3`, `min.insync.replicas=2`): every message is written to 3 brokers before it's considered durable, and at least 2 must acknowledge a write for it to succeed — the cluster tolerates one broker failing without losing data or blocking writes.
- **Encryption in transit (TLS)**: both client-to-broker and broker-to-broker traffic is encrypted, so data moving between services or across AZs isn't readable on the wire.
- **`auto.create.topics.enable=false`**: topics must be explicitly created (via Terraform/CI, not implicitly by whichever producer happens to write first) — this avoids typo'd topic names silently creating new, mis-configured topics in production.
- **Enhanced monitoring**: per-topic, per-broker metrics (CPU, disk, request latency) feed into CloudWatch/Datadog so consumer lag or a hot partition is visible before it causes an outage.

## Why it's needed
Services that need to react to events (a price update, a new order, a config change) as they happen — rather than polling a database — need an ordered, durable, replayable event log between them. Kafka is the de-facto standard for that; MSK removes the operational burden (broker patching, ZooKeeper/KRaft management, scaling storage) of running it yourself.
