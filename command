orca-security-us Bot reviewed 13 minutes ago
s3.tf
Resolved
role.tf
  }
}

resource "aws_iam_role" "s3_role" {
@orca-security-us
orca-security-us Bot
13 minutes ago
⚪️ [INFO] IAM Access Analyzer Is Not Enabled
Details:
IAM Access Analyzer continuously monitors resource policies to identify
unintended external access to AWS resources. Without it, overly permissive
policies may grant unauthorized access to S3 buckets, IAM roles, or other
resources. Enable an analyzer to detect and remediate external access risks.

Recommendation:
'aws_accessanalyzer_analyzer' should be set

💡 Reply /orca fix to have Orca suggest an AI-generated fix for this finding.

@T012SP_kyfb	Reply...
s3.tf
@@ -0,0 +1,101 @@
resource "aws_s3_bucket" "photos" {
@orca-security-us
orca-security-us Bot
13 minutes ago
⚪️ [INFO] IAM Access Analyzer Is Not Enabled
Details:
IAM Access Analyzer continuously monitors resource policies to identify
unintended external access to AWS resources. Without it, overly permissive
policies may grant unauthorized access to S3 buckets, IAM roles, or other
resources. Enable an analyzer to detect and remediate external access risks.

Recommendation:
'aws_accessanalyzer_analyzer' should be set

💡 Reply /orca fix to have Orca suggest an AI-generated fix for this finding.

@T012SP_kyfb	Reply...
s3.tf
@@ -0,0 +1,101 @@
resource "aws_s3_bucket" "photos" {
@orca-security-us
orca-security-us Bot
13 minutes ago
⚪️ [INFO] S3 Bucket Server Access Logging is Disabled
Details:
Server Access Logging disabled on S3 buckets prevents tracking of access
requests, hindering security monitoring and forensic analysis. Without access
logs, detecting unauthorized data access or policy violations becomes impossible.
Enable Server Access Logging to maintain audit trails.

Recommendation:
'logging' should be defined and not null

💡 Reply /orca fix to have Orca suggest an AI-generated fix for this finding.

@T012SP_kyfb	Reply...
