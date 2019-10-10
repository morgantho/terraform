output "codebuild_role_arn" {
  value = "${aws_iam_role.codebuild_role.arn}"
}

output "codepipeline_role_arn" {
  value = "${aws_iam_role.codepipeline_role.arn}"
}

output "ecs_role_arn" {
  value = "${aws_iam_role.ecs_role.arn}"
}

output "ecs_execution_role_arn" {
  value = "${aws_iam_role.ecs_execution_role.arn}"
}

output "cloudwatch_events_codepipeline_role_arn" {
  value = "${aws_iam_role.cloudwatch_events_codepipeline_role.arn}"
}

output "lambda_role_arn" {
  value = "${aws_iam_role.lambda_role.arn}"
}

output "event_log_role_arn" {
  value = "${aws_iam_role.event_log_role.arn}"
}
