variable "aws_profile" {
  description = "Terraform profile"
}

variable "aws_region" {
  description = "us-east-2"
}

variable "remote_state_key" {
  description = "State file path"
}

variable "remote_state_region" {
  description = "Remote State region"
}

variable "dynamodb_table" {
  default = "DynamoDB table for state locking"
}

/* remote states */
variable "remote_state_bucket" {
  description = "S3 Remote State bucket"
}

variable "iam_remote_state_bucket_key" {
  description = "Remote state bucket key for IAM state file"
}

variable "sg_remote_state_bucket_key" {
  description = "Remote state bucket key for Security Group state file"
}

variable "vpc_remote_state_bucket_key" {
  description = "Remote state bucket key for VPC state file"
}

variable "s3_codepipeline_remote_state_bucket_key" {
  description = "Remote state bucket key for S3 codepipeline bucket"
}

variable "s3_codebuild_remote_state_bucket_key" {
  description = "Remote state bucket key for s3 codebuild bucket state file"
}

variable "cluster_remote_state_bucket_key" {
  description = "Remote state bucket key for Cluster state file"
}

/* codebuild build environment variables */
variable "name" {
  description = "Process Name"
}

variable "build_timeout" {
  description = "Codebuild timeout in minutes"
  default = "60"
}

variable "artifact_type" {
  description = "Codebuild or S3"
  default = "CODEPIPELINE"
}

variable "compute_type" {
  description = "Codebuild instance building size"
  default = "BUILD_GENERAL1_SMALL"
}

variable "image_type" {
  description = "AWS image type, eg. Docker, Java"
  default = "aws/codebuild/docker:17.09.0"
}

variable "env_type" {
  description = "LINUX_CONTAINER"
  default = "LINUX_CONTAINER"
}

variable "env_var_region_name" {
  description = "AWS_DEFAULT_REGION"
  default = "AWS_DEFAULT_REGION"
}

variable "env_var_repo_url" {
  description = "REPOSITORY_URI"
  default = "REPOSITORY_URI"
}

variable "env_var_name" {
  description = "Container name for image_definitions.json and ecr prefix tagging"
  default = "NAME"
}

variable "source_type" {
  description = "Codepipeline or S3"
  default = "CODEPIPELINE"
}

/* ecs variables */
// cloudwatch variables
variable "prefix" {
  description = "Prefix, typically company name related"
}

variable "log_retention" {
  default = "14"
}

// task json variables

variable "task_json_file" {
  description = "Container task defintion file"
}

variable "port" {
  description = "ECS task port"
}

variable "memory" {
  description = "Memory size in MB"
  default = "512"
}

// task defintion variables

variable "compatibilities" {
  description = "Needed for Fargate"
  default = "FARGATE"
}

variable "network_mode" {
  description = "Fargate requires 'awsvpc', EC2 can use 'awsvpc or 'bridged'"
  default = "awsvpc"
}

variable "cpu" {
  description = "Size in MB"
  default = "256"
}

variable "desired_count" {
  description = "Task count"
}

variable "launch_type" {
  description = "Fargate / EC2"
  default = "FARGATE"
}

variable "public_ip" {
  description = "Auto-assign public IP (true/false)"
  default = "false"
}
