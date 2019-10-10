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

/* codebuild role, policy, and policy attachment */
resource "aws_iam_role" "codebuild_role" {
    name = "codebuild_role"
    assume_role_policy = "${file("${path.module}/policies/codebuild_role.json")}"
}

data "template_file" "codebuild_policy_json" {
  template = "${file("${path.module}/policies/codebuild_policy.json")}"
  vars {
    aws_s3_bucket_arn = "${var.bucket_arn}"
  }
}

resource "aws_iam_policy" "codebuild_policy" {
    name = "codebuild_policy"
    policy = "${data.template_file.codebuild_policy_json.rendered}"
}

resource "aws_iam_role_policy_attachment" "codebuild_role" {
    role = "${aws_iam_role.codebuild_role.name}"
    policy_arn = "${aws_iam_policy.codebuild_policy.arn}"
}

/* ecs role, policy, and policy attachment */
resource "aws_iam_role" "ecs_role" {
    name = "ecs_role"
    assume_role_policy = "${file("${path.module}/policies/ecs_role.json")}"
}

resource "aws_iam_policy" "ecs_service_role_policy" {
    policy = "${file("${path.module}/policies/ecs_service_role_policy.json")}"
}

resource "aws_iam_role_policy_attachment" "ecs_role" {
    role = "${aws_iam_role.ecs_role.name}"
    policy_arn = "${aws_iam_policy.ecs_service_role_policy.arn}"
}

resource "aws_iam_role" "ecs_execution_role" {
    name = "ecs_execution_role"
    assume_role_policy = "${file("${path.module}/policies/ecs_task_execution_role.json")}"
}

resource "aws_iam_policy" "ecs_execution_role_policy" {
    name = "ecs_execution_role_policy"
    policy = "${file("${path.module}/policies/ecs_execution_role_policy.json")}"
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role" {
    role = "${aws_iam_role.ecs_execution_role.name}"
    policy_arn = "${aws_iam_policy.ecs_execution_role_policy.arn}"
}

/* codepipeline role, policy, and policy attachment */
resource "aws_iam_role" "codepipeline_role" {
    name = "codepipeline_role"
    assume_role_policy = "${file("${path.module}/policies/codepipeline_role.json")}"
}

resource "aws_iam_policy" "codepipeline_policy" {
    name = "codepipeline_policy"
    policy = "${file("${path.module}/policies/codepipeline_policy.json")}"
}

resource "aws_iam_role_policy_attachment" "codepipeline_role" {
    role = "${aws_iam_role.codepipeline_role.name}"
    policy_arn = "${aws_iam_policy.codepipeline_policy.arn}"
}

/* cloudwatch codepipeline event role */
resource "aws_iam_role" "cloudwatch_events_codepipeline_role" {
    name = "start_codepipeline_role"
    path = "/service-role/"
    assume_role_policy = "${file("${path.module}/policies/cloudwatch_event_codepipeline_role.json")}"
}

resource "aws_iam_policy" "cloudwatch_events_codepipeline_policy" {
    name = "cloudwatch_events_codepipeline_policy"
    policy = "${file("${path.module}/policies/cloudwatch_event_codepipeline_policy.json")}"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_events_codepipeline_role" {
    role = "${aws_iam_role.cloudwatch_events_codepipeline_role.name}"
    policy_arn = "${aws_iam_policy.cloudwatch_events_codepipeline_policy.arn}"
}

/* lambda role */
resource "aws_iam_role" "lambda_role" {
    name = "lambda_role"
    assume_role_policy = "${file("${path.module}/policies/lambda_role.json")}"
}

resource "aws_iam_policy" "lambda_role_policy" {
    name = "lambda_role_policy"
    policy = "${file("${path.module}/policies/lambda_role_policy.json")}"
}

resource "aws_iam_role_policy_attachment" "lambda_role" {
    role = "${aws_iam_role.lambda_role.name}"
    policy_arn = "${aws_iam_policy.lambda_role_policy.arn}"
}

/* deny region access policy */
resource "aws_iam_policy" "deny_region_access" {
    name = "DenyRegionAccess"
    policy = "${file("${path.module}/policies/denyregionaccess_policy.json")}"
}

/* aws event for security logging role */
resource "aws_iam_role" "event_log_role" {
    name = "AWS_Event_Invoke_Event_Bus"
    assume_role_policy = "${file("${path.module}/policies/event_log_role.json")}"
}

resource "aws_iam_policy" "event_log_role_policy" {
    name = "AWS_Event_Invoke_Event_Bus"
    policy = "${file("${path.module}/policies/AWS_Event_Invoke_Event_Bus_policy.json")}"
}

resource "aws_iam_role_policy_attachment" "event_log_role" {
    role = "${aws_iam_role.event_log_role.name}"
    policy_arn = "${aws_iam_policy.event_log_role_policy.arn}"
}
