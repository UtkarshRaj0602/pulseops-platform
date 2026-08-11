resource "aws_iam_role" "eks_cluster" {

  name = "${local.name_prefix}-eks-cluster-role"

  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume_role.json

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-eks-cluster-role"
    }
  )

}

resource "aws_iam_role" "eks_node" {

  name = "${local.name_prefix}-eks-node-role"

  assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role.json

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-eks-node-role"
    }
  )

}

resource "aws_iam_role_policy" "eks_node_sqs" {
  name = "${var.environment}-eks-node-sqs"
  role = aws_iam_role.eks_node.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = var.sqs_queue_arn
      }
    ]
  })
}

# resource "aws_iam_role" "github_actions" {

#   name = "${local.name_prefix}-github-actions-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"

#     Statement = [
#       {
#         Effect = "Allow"

#         Principal = {
#           Federated = "arn:aws:iam::051826706795:oidc-provider/token.actions.githubusercontent.com"
#         }

#         Action = "sts:AssumeRoleWithWebIdentity"

#         Condition = {
#           StringEquals = {
#             "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com",

#             "token.actions.githubusercontent.com:sub" = "repo:UtkarshRaj0602@65725785/pulseops-platform@1321276675:ref:refs/heads/stage"
#           }
#         }
#       }
#     ]
#   })
# }

#   tags = merge(
#     local.common_tags,
#     {
#       Name = "${local.name_prefix}-github-actions-role"
#     }
#   )
# }

# resource "aws_iam_role_policy" "github_actions_ecr" {

#   name = "${local.name_prefix}-github-actions-ecr"

#   role = aws_iam_role.github_actions.id

#   policy = jsonencode({
#     Version = "2012-10-17"

#     Statement = [

#       {
#         Effect = "Allow"

#         Action = [
#           "ecr:GetAuthorizationToken"
#         ]

#         Resource = "*"
#       },

#       {
#         Effect = "Allow"

#         Action = [
#           "ecr:BatchCheckLayerAvailability",
#           "ecr:CompleteLayerUpload",
#           "ecr:InitiateLayerUpload",
#           "ecr:PutImage",
#           "ecr:UploadLayerPart",
#           "ecr:BatchGetImage",
#           "ecr:GetDownloadUrlForLayer"
#         ]

#         Resource = "arn:aws:ecr:ap-south-1:051826706795:repository/pulseops-*"
#       }

#     ]
#   })
# }
