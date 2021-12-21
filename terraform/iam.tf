resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  thumbprint_list = ["a031c46782e6e6c662c2c87c76da9aa62ccabd8e"]
  client_id_list  = ["sts.amazonaws.com"]
}

resource "aws_iam_role" "github_actions" {
  name               = "github-actions-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.id]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${var.github_user_name}/${var.github_repository_name}:*",
      ]
    }
  }
}

resource "aws_iam_role_policy" "github_actions" {
  name   = "github-actions-role-policy"
  role   = aws_iam_role.github_actions.id
  policy = data.aws_iam_policy_document.github_actions.json
}

data "aws_iam_policy_document" "github_actions" {
  statement {
    effect = "Allow"
    resources = [
      aws_s3_bucket.s3_bucket.arn,
      "${aws_s3_bucket.s3_bucket.arn}/*",
    ]
    actions = ["*"]
  }
}
