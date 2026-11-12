Copilot AI
left a comment
🟡 Changes recommended
The S3 backend lacks state locking, risking conflicting concurrent applies and overwritten state, alongside unresolved upload CORS, versioning, and ineffective access-prefix input issues.

4 open issues
High severity Enable state locking for the S3 backend · New
Medium severity Suspend versioning instead of disabling it · New
Medium severity Allow PUT in CORS for direct uploads · New
Medium severity Remove the unused object_prefix input · New
What changed in this PR
Review effort: Balanced

versions.tf
Comment on lines +11 to +15
  backend "s3" {
    bucket = "kfb-github-terraform-state"
    key    = "tf-aws-kfb-events-infra/terraform.tfstate"
    region = "us-east-1"
  }
Copilot commented 5 minutes ago
Copilot
Copilot
AI
5m ago
High
Enable state locking for the S3 backend
This backend does not enable state locking, so concurrent applies using this configuration can make conflicting infrastructure changes and overwrite state updates. Enable S3 lockfiles or DynamoDB locking, with compatible tooling and the required backend permissions.

Copilot uses AI. Check for mistakes.
@T012SP_kyfb	Reply...
s3.tf
Resolved
s3.tf
  bucket = aws_s3_bucket.photos.id

  cors_rule {
    allowed_methods = ["GET", "HEAD", "POST"]
Copilot commented 5 minutes ago
Copilot
Copilot
AI
5m ago
Medium
Allow PUT in CORS for direct uploads
The documented direct-upload flow uses a pre-signed PUT URL, but this CORS rule allows only GET, HEAD, and POST. A browser's preflight for PUT will fail even for the configured origins, preventing direct uploads. Add PUT to the allowed methods.

Suggested changeset 1 (1)
s3.tf
Original file line number	Diff line number	Diff line change
   bucket = aws_s3_bucket.photos.id
   cors_rule {
     allowed_methods = ["GET", "HEAD", "POST"]
     allowed_methods = ["GET", "HEAD", "POST", "PUT"]
     allowed_origins = var.cors_allowed_origins
     allowed_headers = ["Content-Type"]
     max_age_seconds = 3000
Copilot uses AI. Check for mistakes.
@T012SP_kyfb	Reply...
variables.tf
Resolved
