role.tf:

data "aws_iam_policy_document" "s3_role_assume_role_policy" {
  statement {
    sid     = "AllowGoogleServiceAccount"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["accounts.google.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "accounts.google.com:aud"
      values   = [var.google_sa_unique_id]
    }

    condition {
      test     = "StringEquals"
      variable = "accounts.google.com:sub"
      values   = [var.google_sa_unique_id]
    }

    condition {
      test     = "StringEquals"
      variable = "accounts.google.com:oaud"
      values   = [var.token_audience]
    }
  }
}

resource "aws_iam_role" "s3_role" {
  name                 = "kfb-events-s3-role-${var.environment}"
  assume_role_policy   = data.aws_iam_policy_document.s3_role_assume_role_policy.json
  max_session_duration = 3600
}

locals {
  object_actions = concat(
    ["s3:PutObject", "s3:GetObject"],
    var.allow_delete ? ["s3:DeleteObject"] : []
  )
}

data "aws_iam_policy_document" "s3_role_policy" {
  statement {
    sid       = "PhotoObjectsOnly"
    effect    = "Allow"
    actions   = local.object_actions
    resources = ["${aws_s3_bucket.photos.arn}/${var.object_prefix}*"]
  }

  dynamic "statement" {
    for_each = var.use_kms ? [1] : []
    content {
      sid       = "UsePhotoKmsKey"
      effect    = "Allow"
      actions   = ["kms:GenerateDataKey", "kms:Decrypt"]
      resources = [var.kms_key_arn]
    }
  }
}

resource "aws_iam_policy" "s3_role_policy" {
  name   = "kfb-events-s3-role-policy-${var.environment}"
  policy = data.aws_iam_policy_document.s3_role_policy.json
}

variables.tf:


variable "google_sa_unique_id" {
  description = "Unique numeric ID of the Google service account allowed to assume the role"
  type        = string
}

variable "token_audience" {
  description = "Audience the function requests on its Google ID token"
  type        = string
}

variable "object_prefix" {
  description = "Folder in the bucket the role can use"
  type        = string
  default     = "photos/"
}

variable "allow_delete" {
  description = "Let the role delete photos (false if the app never deletes)"
  type        = bool
  default     = true
}

resource "aws_iam_role_policy_attachment" "s3_role_policy" {
  role       = aws_iam_role.s3_role.name
  policy_arn = aws_iam_policy.s3_role_policy.arn
}
