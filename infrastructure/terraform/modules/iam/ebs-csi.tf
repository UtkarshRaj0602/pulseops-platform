data "aws_iam_policy_document" "ebs_csi_assume_role" {

  statement {

    effect = "Allow"

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]

    principals {

      type = "Service"

      identifiers = [
        "pods.eks.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "ebs_csi" {

  name = "${local.name_prefix}-ebs-csi-role"

  assume_role_policy = data.aws_iam_policy_document.ebs_csi_assume_role.json

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-ebs-csi-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "ebs_csi" {

  role = aws_iam_role.ebs_csi.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}
