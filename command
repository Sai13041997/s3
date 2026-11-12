orca-security-us Bot reviewed 3 minutes ago
s3.tf
@@ -0,0 +1,81 @@
resource "aws_s3_bucket" "photos" {
@orca-security-us
orca-security-us Bot
3 minutes ago
🟡 [LOW] S3 Bucket Object Versioning not Enabled
Details:
S3 buckets without versioning enabled cannot recover from accidental deletions or
overwrites, leading to permanent data loss. Versioning maintains multiple object
variants for recovery and audit purposes. Enable versioning to protect against
unintended modifications.

Recommendation:
'versioning' should be true

💡 Reply /orca fix to have Orca suggest an AI-generated fix for this finding.

@T012SP_kyfb	Reply...
