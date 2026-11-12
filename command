s3.tf:

resource "aws_s3_bucket_lifecycle_configuration" "photos" {
  bucket = aws_s3_bucket.photos.id

  rule {
    id     = "abort-incomplete-uploads"
    status = "Enabled"
    filter {}
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

data "aws_iam_policy_document" "photos_bucket" {
  statement {
    sid     = "DenyNonTLS"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.photos.arn,
      "${aws_s3_bucket.photos.arn}/*",
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "photos" {
  bucket     = aws_s3_bucket.photos.id
  policy     = data.aws_iam_policy_document.photos_bucket.json
  depends_on = [aws_s3_bucket_public_access_block.photos]
}

resource "aws_s3_bucket_cors_configuration" "photos" {
  count  = length(var.cors_allowed_origins) > 0 ? 1 : 0
  bucket = aws_s3_bucket.photos.id

  cors_rule {
    allowed_methods = ["GET", "HEAD", "POST"]
    allowed_origins = var.cors_allowed_origins
    allowed_headers = ["Content-Type"]
    max_age_seconds = 3000
  }
}







variable "object_prefixes" {
  description = "Folders in the bucket the role can use"
  type        = list(string)
  default     = ["photos/"]
}

variable "allow_delete" {
  description = "Let the role delete photos (false if the app never deletes)"
  type        = bool
  default     = true
}








git add s3.tf variables.tf role.tf
git commit -m "Merge remote changes"
git push origin feature/T012SP/HC-77160
