provider "aws" {
  region = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

terraform {
  backend "s3" {
    bucket = "${var.remote_state_bucket}"
    key = "${var.remote_state_key}"
    region = "${var.remote_state_region}"
    dynamodb_table = "${var.dynamodb_table}"
  }
}

/* remote states */

data "terraform_remote_state" "codebuild_bucket" {
  backend = "s3"
  config = {
    bucket = "${var.remote_state_bucket}"
    key = "${var.s3_codebuild_remote_state_bucket_key}"
    region = "${var.aws_region}"
  }
}

data "terraform_remote_state" "roles" {
  backend = "s3"
  config = {
    bucket = "${var.remote_state_bucket}"
    key = "${var.iam_remote_state_bucket_key}"
    region = "${var.aws_region}"
  }
}

data "terraform_remote_state" "cluster" {
  backend = "s3"
  config = {
    bucket = "${var.remote_state_bucket}"
    key = "${var.cluster_remote_state_bucket_key}"
    region = "${var.aws_region}"
  }
}

data "terraform_remote_state" "codepipeline_bucket" {
  backend = "s3"
  config = {
    bucket = "${var.remote_state_bucket}"
    key = "${var.s3_codepipeline_remote_state_bucket_key}"
    region = "${var.aws_region}"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "${var.remote_state_bucket}"
    key = "${var.vpc_remote_state_bucket_key}"
    region = "${var.aws_region}"
  }
}

data "terraform_remote_state" "security_group" {
  backend = "s3"
  config = {
    bucket = "${var.remote_state_bucket}"
    key = "${var.sg_remote_state_bucket_key}"
    region = "${var.aws_region}"
  }
}

/* CODEBUILD */
/* specific codebuild "folder" */

resource "aws_s3_bucket_object" "codebuild_bucket" {
    bucket  = "${data.terraform_remote_state.codebuild_bucket.bucket_id}"
    key     = "${var.name}/"
    source  = "/dev/null"
}

/* ecr repo */
resource "aws_ecr_repository" "ecr_repo" {
    name = "${var.name}"
}

/* codebuild project */
// CODEPIPELINE SOURCE
resource "aws_codebuild_project" "project" {
    name          = "${var.name}-build"
    description   = "${var.name} Codebuild project"
    build_timeout = "${var.build_timeout}"
    service_role  = "${data.terraform_remote_state.roles.codebuild_role_arn}"

    artifacts {
      type = "${var.artifact_type}"
    }

    environment {
      compute_type    = "${var.compute_type}"
      image           = "${var.image_type}"
      type            = "${var.env_type}"
      privileged_mode = true

      environment_variable {
        "name"  = "${var.env_var_region_name}"
        "value" = "${var.aws_region}"
      }

      environment_variable {
        "name"  = "${var.env_var_repo_url}"
        "value" = "${aws_ecr_repository.ecr_repo.repository_url}"
      }

      environment_variable {
        "name"  = "${var.env_var_name}"
        "value" = "${var.name}"
      }
    }

    source {
      type  = "${var.source_type}"
    }
}

/* ECS SERVICE */

resource "aws_cloudwatch_log_group" "ecs_service_logs" {
    name = "/${var.prefix}/${var.name}"
    retention_in_days = "${var.log_retention}"
}

data "template_file" "task_json" {
  template = "${file("${path.module}/tasks/${var.task_json_file}")}"

  vars {
    name      = "${var.name}"
    port      = "${var.port}"
    network   = "${var.network_mode}"
    image     = "${aws_ecr_repository.ecr_repo.repository_url}"
    memory    = "${var.memory}"
    log_group = "/${var.prefix}/${var.name}"
    region    = "${var.aws_region}"
  }
}

resource "aws_ecs_task_definition" "task" {
    family                    = "${var.name}"
    container_definitions     = "${data.template_file.task_json.rendered}"
    requires_compatibilities  = ["${var.compatibilities}"]
    network_mode              = "${var.network_mode}"
    cpu                       = "${var.cpu}"
    memory                    = "${var.memory}"
    execution_role_arn        = "${data.terraform_remote_state.roles.ecs_execution_role_arn}"
    task_role_arn             = "${data.terraform_remote_state.roles.ecs_execution_role_arn}"
}

data "aws_ecs_task_definition" "task" {
  task_definition = "${aws_ecs_task_definition.task.family}"
  depends_on      = ["aws_ecs_task_definition.task"]
}

resource "aws_ecs_service" "ecs_service" {
    name            = "${var.name}"
    cluster         = "${data.terraform_remote_state.cluster.cluster_id}"
    task_definition = "${aws_ecs_task_definition.task.family}:${max("${aws_ecs_task_definition.task.revision}", "${data.aws_ecs_task_definition.task.revision}")}"
    desired_count   = "${var.desired_count}"
    launch_type     = "${var.launch_type}"

    lifecycle {
      ignore_changes = ["desired_count"]
    }

    network_configuration {
      security_groups = ["${data.terraform_remote_state.security_group.security_group_id}"]
      subnets         = ["${data.terraform_remote_state.vpc.subnet_ids}"]
      assign_public_ip = "${var.public_ip}"
    }
}

/* CODEPIPELINE */
resource "aws_codepipeline" "pipeline" {
  name      = "${var.name}"
  role_arn  = "${data.terraform_remote_state.roles.codepipeline_role_arn}"

  artifact_store {
    location  = "${data.terraform_remote_state.codepipeline_bucket.bucket_id}"
    type = "S3"
    }

  stage {
    name = "Source"

    action {
      name = "Source"
      category = "Source"
      owner   = "AWS"
      provider = "S3"
      version = "1"
      output_artifacts = ["source"]

      configuration {
        S3Bucket = "${data.terraform_remote_state.codebuild_bucket.bucket_id}/${var.name}"
        S3ObjectKey = "${var.name}.zip"
        PollForSourceChanges = "false"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name = "Build"
      category = "Build"
      owner   = "AWS"
      provider = "CodeBuild"
      version = "1"
      input_artifacts   = ["source"]
      output_artifacts = ["imagedefinitions"]

      configuration {
        ProjectName = "${var.name}-build"
      }
    }
  }

  stage {
    name = "Production"

    action {
      name = "Deploy"
      category = "Deploy"
      owner   = "AWS"
      provider = "ECS"
      version = "1"
      input_artifacts   = ["imagedefinitions"]

      configuration {
        ClusterName = "${data.terraform_remote_state.cluster.cluster_id}"
        ServiceName = "${aws_ecs_service.ecs_service.name}"
        FileName = "imagedefinitions.json"
      }
    }
  }
}

data "template_file" "event_rule_json" {
  template = "${file("${path.module}/event_rule.json")}"

  vars {
    codebuild_bucket = "${data.terraform_remote_state.codebuild_bucket.bucket_id}"
    name      = "${var.name}"
  }
}

resource "aws_cloudwatch_event_rule" "event_codepipeline" {
    name = "isfs.sys.codepipeline.${var.name}"
    description = "Triggers ${var.name} codepipeline to build from S3 changes."
    event_pattern = "${data.template_file.event_rule_json.rendered}"

}

resource "aws_cloudwatch_event_target" "codepipeline_target" {
    rule      = "${aws_cloudwatch_event_rule.event_codepipeline.name}"
    arn       = "${aws_codepipeline.pipeline.arn}"
    role_arn  = "${data.terraform_remote_state.roles.cloudwatch_events_codepipeline_role_arn}"
}
