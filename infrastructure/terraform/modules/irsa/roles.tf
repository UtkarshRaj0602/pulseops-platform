resource "aws_iam_role" "alb_controller" {

  name = "${local.name_prefix}-alb-controller-role"

  assume_role_policy = data.aws_iam_policy_document.alb_controller_assume_role.json

  tags = local.common_tags

}

resource "aws_iam_role" "ebs_csi" {

  name = "${local.name_prefix}-ebs-csi-role"

  assume_role_policy = data.aws_iam_policy_document.ebs_csi_assume_role.json

  tags = local.common_tags

}

resource "aws_iam_role" "external_secrets" {

  name = "${local.name_prefix}-external-secrets-role"

  assume_role_policy = data.aws_iam_policy_document.external_secrets_assume_role.json

  tags = local.common_tags

}
