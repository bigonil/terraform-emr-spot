resource "aws_emr_cluster" "this" {
  name             = var.cluster_name
  release_label    = var.emr_release
  applications     = ["Spark", "Hadoop"]
  log_uri          = var.log_uri
  service_role     = aws_iam_role.emr_service.arn
  #autoscaling_role = aws_iam_role.emr_autoscaling.arn
  ec2_attributes {
    subnet_id                         = var.subnet_id
    emr_managed_master_security_group = aws_security_group.emr_master.id
    emr_managed_slave_security_group  = aws_security_group.emr_core.id
    instance_profile                  = aws_iam_instance_profile.emr_ec2_profile.arn
  }

  master_instance_fleet {
    name = "master"

    instance_type_configs {
      instance_type     = "m5.xlarge"
      weighted_capacity = 1
    }

    target_on_demand_capacity = 1
  }

  core_instance_fleet {
    name = "core"

    instance_type_configs {
      instance_type                              = "m5.xlarge"
      weighted_capacity                          = 1
      bid_price_as_percentage_of_on_demand_price = 80
    }

    instance_type_configs {
      instance_type                              = "r5.xlarge"
      weighted_capacity                          = 1
      bid_price_as_percentage_of_on_demand_price = 80
    }

    launch_specifications {
      spot_specification {
        timeout_duration_minutes = 10
        timeout_action           = "SWITCH_TO_ON_DEMAND"
        allocation_strategy = "capacity-optimized"
      }
    }

    target_spot_capacity = 2
  }

  step_concurrency_level            = 1
  visible_to_all_users              = true
  scale_down_behavior               = "TERMINATE_AT_TASK_COMPLETION"
  termination_protection            = false
  keep_job_flow_alive_when_no_steps = true
}

resource "aws_security_group" "emr_master" {
  name        = "emr-master-sg"
  description = "EMR Master SG"
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_security_group" "emr_core" {
  name        = "emr-core-sg"
  description = "EMR Core SG"
  vpc_id      = data.aws_vpc.default.id
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_iam_role" "emr_service" {
  name               = "EMR_DefaultRole"
  assume_role_policy = data.aws_iam_policy_document.emr_service.json
}

resource "aws_iam_role" "emr_autoscaling" {
  name               = "EMR_AutoScaling_DefaultRole"
  assume_role_policy = data.aws_iam_policy_document.emr_autoscaling.json
}

resource "aws_iam_role" "emr_ec2" {
  name               = "EMR_EC2_DefaultRole"
  assume_role_policy = data.aws_iam_policy_document.emr_ec2.json
}

resource "aws_iam_instance_profile" "emr_ec2_profile" {
  name = "EMR_EC2_DefaultRole"
  role = aws_iam_role.emr_ec2.name
}

data "aws_iam_policy_document" "emr_service" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["elasticmapreduce.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "emr_autoscaling" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["application-autoscaling.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "emr_ec2" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}