🟡 Changes recommended
Production S3 versioning and the documented 30-day noncurrent-version lifecycle rule are missing, leaving overwritten or deleted photos unrecoverable.

1 open issue
High severity Enable production bucket versioning and the 30-day lifecycle rule · New
4 resolved since last review
Review effort: Balanced

s3.tf
Comment on lines +1 to +3
resource "aws_s3_bucket" "photos" {
  bucket = "kfb-events-photos-${var.environment}"
}
Copilot commented 1 minute ago
Copilot
Copilot
AI
1m ago
High
Enable production bucket versioning and the 30-day lifecycle rule
The PR description and README promise versioning in production, but there is no aws_s3_bucket_versioning resource or enable_versioning input, and envs/prod.tfvars does not enable it. A newly deployed production bucket will therefore permanently lose overwritten or deleted photos rather than retain recoverable versions. Add the production versioning configuration and the documented 30-day noncurrent-version lifecycle rule.

Copilot uses AI. Check for mistakes.
@T012SP_kyfb	Reply...
