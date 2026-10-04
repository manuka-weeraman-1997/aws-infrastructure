variable "cluster_name" {
  type = string
}

variable "broker_count" {
  type    = number
  default = 3
}

variable "broker_instance_type" {
  type    = string
  default = "kafka.m5.large"
}

variable "subnet_ids" {
  type = list(string)
}

variable "broker_volume_size_gb" {
  type    = number
  default = 100
}

variable "vpc_id" {
  type = string
}

variable "vpc_cidr" {
  type = string
}
