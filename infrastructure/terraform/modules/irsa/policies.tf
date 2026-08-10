resource "aws_iam_policy" "alb_controller" {

  name        = "${local.name_prefix}-alb-controller-policy"
  description = "AWS Load Balancer Controller IAM Policy"

  policy = file("${path.module}/policies/aws-load-balancer-controller.json")

  tags = local.common_tags
}

data "aws_iam_policy_document" "external_secrets_policy" {

  statement {

    effect = "Allow"

    actions = [

      "secretsmanager:GetSecretValue",

      "secretsmanager:DescribeSecret"

    ]

    resources = [

      "*"

    ]

  }

}

resource "aws_iam_policy" "external_secrets" {

  name = "${local.name_prefix}-external-secrets-policy"

  policy = data.aws_iam_policy_document.external_secrets_policy.json

}

data "aws_iam_policy_document" "worker_policy" {

  statement {

    effect = "Allow"

    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes"
    ]

    resources = [
      var.sqs_queue_arn
    ]
  }
}

resource "aws_iam_policy" "worker" {

  name = "${local.name_prefix}-worker-policy"

  policy = data.aws_iam_policy_document.worker_policy.json

  tags = local.common_tags
}
