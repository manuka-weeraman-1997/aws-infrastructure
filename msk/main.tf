# Example: Amazon MSK (Managed Streaming for Kafka) cluster.

resource "aws_msk_cluster" "this" {
  cluster_name          = var.cluster_name
  kafka_version         = "3.6.0"
  number_of_broker_nodes = var.broker_count

  broker_node_group_info {
    instance_type   = var.broker_instance_type
    client_subnets  = var.subnet_ids
    security_groups = [aws_security_group.msk.id]

    storage_info {
      ebs_storage_info {
        volume_size = var.broker_volume_size_gb
      }
    }
  }

  encryption_info {
    encryption_in_transit {
      client_broker = "TLS"
      in_cluster    = true
    }
  }

  configuration_info {
    arn      = aws_msk_configuration.this.arn
    revision = aws_msk_configuration.this.latest_revision
  }

  enhanced_monitoring = "PER_TOPIC_PER_BROKER"
}

resource "aws_msk_configuration" "this" {
  name           = "${var.cluster_name}-config"
  kafka_versions = ["3.6.0"]
  server_properties = <<-PROPERTIES
    auto.create.topics.enable=false
    default.replication.factor=3
    min.insync.replicas=2
  PROPERTIES
}

resource "aws_security_group" "msk" {
  name   = "${var.cluster_name}-msk-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 9094
    to_port     = 9094
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
}
