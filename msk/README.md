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

---

## Reference implementation: end-to-end streaming on Amazon MSK

![MSK vs Event Hubs data flow](https://raw.githubusercontent.com/manuka-weeraman-1997/msk-vs-azure-event-hubs/main/docs/images/msk-vs-event-hubs.gif)

```text
Application -> Producer -> Network -> Streaming Platform -> Topic / Event Hub
            -> Partitions -> Consumer Group -> Consumer -> Downstream Application
```

The example system is a market-data pipeline: a producer publishes `market-events` keyed by `symbol`, the stream has four partitions, and the consumer group `search-service` reads with one consumer per partition. The producer, consumer, Terraform, diagrams and docs all describe this same flow.

The minimal cluster in [`main.tf`](main.tf) above is the core pattern. The folders below extend it into a complete, runnable flow.

### What is in this folder

| Path | Purpose |
|---|---|
| [`main.tf`](main.tf), [`variables.tf`](variables.tf) | The original minimal MSK example |
| [`aws/terraform/`](aws/terraform) | Fuller Terraform: VPC, private subnets, security groups, MSK with TLS and SASL/IAM, CloudWatch logs and alarms |
| [`aws/README.md`](aws/README.md) | How to run the fuller Terraform and what it does not do |
| [`producer/`](producer/README.md) | Python producer (`KAFKA_PLATFORM=msk`), partition key = `symbol` |
| [`consumer/`](consumer/README.md) | Python consumer in group `search-service`, manual offset commits, graceful shutdown |
| [`kafka/`](kafka/README.md) | Topic design (`market-events`, 4 partitions, 24 hour retention) and client properties examples |
| [`examples/`](examples) | Event schema and sample events |
| [`diagrams/`](diagrams/architecture.md) | Mermaid diagrams: MSK, Event Hubs, side by side, migration |
| [`scripts/`](scripts) | `setup.sh`, `test-connectivity.sh`, `cleanup.sh` |

### Run it

```bash
bash scripts/setup.sh                 # venv and dependencies
export KAFKA_PLATFORM=msk
# set KAFKA_BOOTSTRAP_SERVERS and AWS_REGION as described in producer/README.md
bash scripts/test-connectivity.sh
```

Topics are created with Kafka admin tooling, not Terraform. See [`kafka/README.md`](kafka/README.md). Running Terraform creates billable resources, so read [`aws/README.md`](aws/README.md) first.

### Conceptual mapping to Azure

| Concept | Amazon MSK | Azure Event Hubs |
|---|---|---|
| Producer | Kafka Producer | Event Producer |
| Streaming platform | Amazon MSK | Event Hubs Namespace |
| Topic | Kafka Topic | Event Hub |
| Partition | Kafka Partition | Event Hubs Partition |
| Consumer group | Kafka Consumer Group | Event Hubs Consumer Group |
| Consumer | Kafka Consumer | Event Consumer |
| Monitoring | CloudWatch | Azure Monitor |

These are conceptual mappings, not exact 1:1 equivalents. Amazon MSK is managed Apache Kafka. Azure Event Hubs is a managed event streaming service that exposes a Kafka-compatible endpoint, so topics are event hubs and several Kafka internals (replication, ISR) are managed by the service instead of exposed. See the [compatibility matrix](https://github.com/manuka-weeraman-1997/msk-vs-azure-event-hubs/blob/main/migration/compatibility-matrix.md).

The Azure counterpart is [`azure-infrastructure/event-hubs`](https://github.com/manuka-weeraman-1997/azure-infrastructure/tree/main/event-hubs).

### Deeper documentation (hub repository)

| Topic | Link |
|---|---|
| Architecture | [architecture.md](https://github.com/manuka-weeraman-1997/msk-vs-azure-event-hubs/blob/main/docs/architecture.md) |
| End-to-end data flow | [data-flow.md](https://github.com/manuka-weeraman-1997/msk-vs-azure-event-hubs/blob/main/docs/data-flow.md) |
| Amazon MSK | [msk.md](https://github.com/manuka-weeraman-1997/msk-vs-azure-event-hubs/blob/main/docs/msk.md) |
| Azure Event Hubs | [azure-event-hubs.md](https://github.com/manuka-weeraman-1997/msk-vs-azure-event-hubs/blob/main/docs/azure-event-hubs.md) |
| Comparison | [comparison.md](https://github.com/manuka-weeraman-1997/msk-vs-azure-event-hubs/blob/main/docs/comparison.md) |
| Security | [security.md](https://github.com/manuka-weeraman-1997/msk-vs-azure-event-hubs/blob/main/docs/security.md) |
| Networking | [networking.md](https://github.com/manuka-weeraman-1997/msk-vs-azure-event-hubs/blob/main/docs/networking.md) |
| Observability | [observability.md](https://github.com/manuka-weeraman-1997/msk-vs-azure-event-hubs/blob/main/docs/observability.md) |
| Migration guide | [kafka-to-event-hubs.md](https://github.com/manuka-weeraman-1997/msk-vs-azure-event-hubs/blob/main/migration/kafka-to-event-hubs.md) |
| Compatibility matrix | [compatibility-matrix.md](https://github.com/manuka-weeraman-1997/msk-vs-azure-event-hubs/blob/main/migration/compatibility-matrix.md) |
| Production checklist | [production-checklist.md](https://github.com/manuka-weeraman-1997/msk-vs-azure-event-hubs/blob/main/docs/production-checklist.md) |
| Cost considerations | [cost-considerations.md](https://github.com/manuka-weeraman-1997/msk-vs-azure-event-hubs/blob/main/docs/cost-considerations.md) |

Everything is also in one place in [`msk-vs-azure-event-hubs`](https://github.com/manuka-weeraman-1997/msk-vs-azure-event-hubs).
