Skip to content
GitHub Enterprise
Users managed by Kentucky Farm Bureau
kfbmic
tf-aws-kfb-events-infra
Repository navigation
Code
Pull requests
1
 (1)
Agents
Actions
Wiki
Security and quality
Insights
Settings
Feature/t012 sp/hc 77160- #1
#1
Open
Praneeth, Sai (T012SP_kyfb)
wants to merge 11 commits into
main
from
feature/T012SP/HC-77160
+453
-24
Lines changed: 453 additions & 24 deletions
Conversation10 (10)
Commits11 (11)
Checks7 (7)
Files changed9 (9)
Open
Feature/t012 sp/hc 77160
#1
Praneeth, Sai (T012SP_kyfb)
wants to merge 11 commits into
main
from
feature/T012SP/HC-77160
Conversation
@T012SP_kyfb
Praneeth, Sai (T012SP_kyfb)
commented
8 minutes ago
This pull request sets up the AWS infrastructure for the KFB Events photo app, enabling secure storage of event photos in S3 and controlled access via a Google service account, all managed with OpenTofu (Terraform). It introduces complete infrastructure-as-code for S3 buckets, IAM roles, policies, and CI/CD workflows, with clear separation between development and production environments.

Infrastructure: S3 Bucket and Security

Adds s3.tf to create a private S3 bucket per environment, with strong security defaults: public access blocked, enforced bucket ownership, server-side encryption (SSE-S3 or KMS), versioning (enabled in prod), lifecycle rules, and a policy to deny non-TLS access. Optional CORS configuration is included for direct browser uploads.
Defines variables in variables.tf for environment, account, encryption, CORS, and IAM settings, supporting flexible deployment and secure defaults.
IAM Role and Access Control

Adds role.tf to create an IAM role with a trust policy allowing only a specific Google service account (identified by unique ID and audience) to assume the role via web identity federation. The role’s policy grants scoped S3 access (only to certain prefixes), with optional KMS permissions, and restricts listing to specific folders.
Environment Configuration

Adds envs/dev.tfvars and envs/prod.tfvars to define per-environment variables, including account IDs, Google service account IDs, CORS origins, and object prefixes. Production enables versioning and restricts CORS origins. [1] [2]
CI/CD Automation

Replaces placeholder GitHub Actions workflows with real workflows for planning and applying infrastructure changes using OpenTofu, supporting workspace selection, secure secret management, and environment mapping. [1] [2]
Documentation

Updates README.md with a detailed explanation of the architecture, security model, deployment process, and repository structure, providing clear context for maintainers and reviewers.
Adds versions.tf to pin Terraform and AWS provider versions, configure the S3 state backend, and set up provider-level tags and role assumption for deployments.
Mention @copilot in a comment to make changes to this pull request.
Schoborg and others added 10 commits last week
SchoborgSchoborg
inital commit to put repo scaffold in place
ae973cc
@T012SP_kyfb
Add S3 photo bucket and Google web-identity role
be22ca7
@T012SP_kyfb
Update README
f6293ad
@T012SP_kyfb
Update README
e2ed743
@T012SP_kyfb
Update README
a916136
@T012SP_kyfb
Add ListBucket permission for photos prefix
ec142b6
@T012SP_kyfb
Add CORS rule for web app uploads and reads
315229c
@T012SP_kyfb
Add resources folder for staff file uploads
2ce5e2e
@T012SP_kyfb
Add prod environment
65d4dc4
@T012SP_kyfb
updated prod environment
c6e7943
@T012SP_kyfb
Praneeth, Sai (T012SP_kyfb) requested a balanced review from Copilot 8 minutes ago
orca-security-us[bot]
orca-security-us Bot reviewed 7 minutes ago
s3.tf
Resolved
role.tf
  }
}

resource "aws_iam_role" "s3_role" {
@orca-security-us
orca-security-us Bot
7 minutes ago
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
7 minutes ago
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
7 minutes ago
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
Copilot started reviewing on behalf of Praneeth, Sai (T012SP_kyfb) 7 minutes ago
orca-security-us[bot]
orca-security-us Bot reviewed 7 minutes ago
orca-security-us Bot
left a comment
Orca Security Scan Summary
Status	Check	Issues by priority	
Passed Passed	Infrastructure as Code	high 0   medium 1   low 0   info 3	View in Orca
Passed Passed	OSS Licenses	high 0   medium 0   low 0   info 0	View in Orca
Passed Passed	SAST	high 0   medium 0   low 0   info 0	View in Orca
Passed Passed	Secrets	high 0   medium 0   low 0   info 0	View in Orca
Passed Passed	Vulnerabilities	high 0   medium 0   low 0   info 0	View in Orca
🛡️ The following IaC misconfigurations have been detected
Copilot AI reviewed 2 minutes ago
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
Copilot commented 2 minutes ago
Copilot
Copilot
AI
2m ago
High
Enable state locking for the S3 backend
This backend does not enable state locking, so concurrent applies using this configuration can make conflicting infrastructure changes and overwrite state updates. Enable S3 lockfiles or DynamoDB locking, with compatible tooling and the required backend permissions.

Copilot uses AI. Check for mistakes.
@T012SP_kyfb	Reply...
s3.tf
resource "aws_s3_bucket_versioning" "photos" {
  bucket = aws_s3_bucket.photos.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
Copilot commented 2 minutes ago
Copilot
Copilot
AI
2m ago
Medium
Suspend versioning instead of disabling it
After versioning has been enabled on a bucket, S3 does not allow it to return to Disabled. Changing enable_versioning from true to false therefore fails instead of turning versioning off. Use Suspended for the false branch so this setting also works for previously versioned buckets.

Suggested changeset 1 (1)
s3.tf
Original file line number	Diff line number	Diff line change
 resource "aws_s3_bucket_versioning" "photos" {
   bucket = aws_s3_bucket.photos.id
   versioning_configuration {
     status = var.enable_versioning ? "Enabled" : "Disabled"
     status = var.enable_versioning ? "Enabled" : "Suspended"
   }
 }
Copilot uses AI. Check for mistakes.
@T012SP_kyfb	Reply...
s3.tf
  bucket = aws_s3_bucket.photos.id

  cors_rule {
    allowed_methods = ["GET", "HEAD", "POST"]
Copilot commented 2 minutes ago
Copilot
Copilot
AI
2m ago
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
Comment on lines +52 to +57
variable "object_prefix" {
  description = "Folder in the bucket the role can use"
  type        = string
  default     = "photos/"
}

Copilot commented 2 minutes ago
Copilot
Copilot
AI
2m ago
Medium
Remove the unused object_prefix input
This input never affects the IAM policy: both object permissions and the listing condition in role.tf use object_prefixes exclusively. A caller setting object_prefix to restrict access to a different folder will silently retain the permissions from object_prefixes. Remove this unused input so callers must use the effective setting.

Suggested changeset 1 (1)
variables.tf
Original file line number	Diff line number	Diff line change
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
Copilot uses AI. Check for mistakes.
@T012SP_kyfb	Reply...
@T012SP_kyfb
Restrict CORS allowed headers to Content-Type
cd335fa
@T012SP_kyfb
Praneeth, Sai (T012SP_kyfb) deployed to nonprod 1 minute ago — with  GitHub Actions Active
orca-security-us[bot]
orca-security-us Bot reviewed 1 minute ago
orca-security-us Bot
left a comment
Orca Security Scan Summary
Status	Check	Issues by priority	
Passed Passed	Infrastructure as Code	high 0   medium 0   low 0   info 3	View in Orca
Passed Passed	OSS Licenses	high 0   medium 0   low 0   info 0	View in Orca
Passed Passed	SAST	high 0   medium 0   low 0   info 0	View in Orca
Passed Passed	Secrets	high 0   medium 0   low 0   info 0	View in Orca
Passed Passed	Vulnerabilities	high 0   medium 0   low 0   info 0	View in Orca
🛡️ The following IaC misconfigurations have been detected
This branch was successfully deployed
1 active deployment
Merge info
All checks have passed
7 successful checks


Merging is blocked
A conversation must be resolved before this pull request can be merged.
Copilot can watch this pull request
Copilot can monitor this pull request for failed Actions workflows and merge conflicts and fix them automatically.


Merge without waiting for requirements to be met (bypass rules)
You can also merge this with the command line. 
Still in progress?
@T012SP_kyfb


Add a comment
Comment
 

Add your comment here...
Remember, contributions to this repository should follow our GitHub Community Guidelines.
 ProTip! Add .patch or .diff to the end of URLs for Git’s plaintext views.
Reviewers
@orca-security-us
orca-security-us[bot]
Copilot code review
Copilot
Copilot review effort
At least 2 approving reviews are required to merge this pull request.

Still in progress?
Assignees
No one—
Labels
None yet
Milestone
No milestone
Development
Successfully merging this pull request may close these issues.

None yet


Notifications
Customize
You’re receiving notifications because you authored the thread.
2 participants
@T012SP_kyfb
 Archive pull request
Footer
© 2026 GitHub, Inc.
Footer navigation
Terms
Privacy
Security
Status
Community
Docs
Contact
Manage cookies
Do not share my personal information
