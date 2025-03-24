variable "region" {
  default = "us-east-1"
}

variable "profile" {
  default = "lb-aws-admin"
}

variable "emr_release" {
  default = "emr-6.15.0"
}

variable "cluster_name" {
  default = "spot-optimized-emr"
}

variable "subnet_id" {
  description = "Subnet for EMR nodes"
  type        = string
}

variable "log_uri" {
  default = "s3://aws-emr-logs-bucket-631737274131/"
}
