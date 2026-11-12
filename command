s3.tf:

resource "aws_s3_bucket" "photos" {
  bucket = "kfb-events-photos-${var.environment}"
}

resource "aws_s3_bucket_public_access_block" "photos" {
  bucket                  = aws_s3_bucket.photos.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "photos" {
  bucket = aws_s3_bucket.photos.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "photos" {
  bucket = aws_s3_bucket.photos.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.use_kms ? "aws:kms" : "AES256"
      kms_master_key_id = var.use_kms ? var.kms_key_arn : null
    }
    bucket_key_enabled = var.use_kms
  }
}



variables.tf: 
variable "environment" {
  type        = string
  description = "Environment to deploy into."
}

variable "destination_account_id" {
  type        = string
  description = "AWS account ID to deploy into (e.g. L2-Development)."
}

variable "use_kms" {
  description = "Use a KMS key instead of SSE-S3 (only if Security requires it)"
  type        = bool
  default     = false
}

variable "kms_key_arn" {
  description = "KMS key ARN, used only when use_kms = true"
  type        = string
  default     = null
}

variable "cors_allowed_origins" {
  description = "Web app origins allowed to call the bucket from a browser. Empty = no CORS."
  type        = list(string)
  default     = []
}

variable "google_sa_unique_id" {
  description = "Unique numeric ID of the Google service account allowed to assume the role"
  type        = string
}

variable "token_audience" {
  description = "Audience the function requests on its Google ID token"
  type        = string
}

role.tf: data "aws_iam_policy_document" "s3_role_assume_role_policy" {
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
    sid       = "AppFoldersOnly"
    effect    = "Allow"
    actions   = local.object_actions
    resources = [for p in var.object_prefixes : "${aws_s3_bucket.photos.arn}/${p}*"]
  }

  statement {
    sid       = "ListAppFoldersOnly"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.photos.arn]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = [for p in var.object_prefixes : "${p}*"]
    }
  }

  dynamic "statement" {
    for_each = var.use_kms ? [1] : []
    content {
      sid       = "UseBucketKmsKey"
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

resource "aws_iam_role_policy_attachment" "s3_role_policy" {
  role       = aws_iam_role.s3_role.name
  policy_arn = aws_iam_policy.s3_role_policy.arn
}
