resource "aws_kms_key" "state" {
  description             = "state"
  deletion_window_in_days = 10
  policy = data.aws_iam_policy_document.key.json
}

resource "aws_kms_alias" "statee" {
  name          = "alias/tf_state_key"
  target_key_id = aws_kms_key.state.key_id
}

data "aws_iam_policy_document" "key" {
  statement {
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = var.root_IAM_arn
    }
  }
  statement {
    actions   = ["kms:Encrypt","kms:Decrypt","kms:ReEncrypt*","kms:GenerateDataKey*","kms:DescribeKey", "kms:CreateGrant", "kms:ListGrants", "kms:RevokeGrant"]
    resources = ["*"]
    condition {
      test = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values = ["true"]
    }
    principals {
      type        = "AWS"
      identifiers = var.authorized_IAM_arn
    }
  }
} 