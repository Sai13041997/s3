README.md:

tf-aws-kfb-events-infra

OpenTofu code for the AWS side of the KFB Events photo app: one private S3 bucket and one IAM role per environment, deployed into the L2 accounts.

Jira: HC-77160 (Help Center) and CPE-296 - "Need help in moving from Google Firebase to AWS S3 for website file backend."

1. Why this exists

The Events app (built and owned by Adam Rayborn, outside core KFB systems) lets people upload event photos from mobile and web. KFB staff review each photo and approve or delete it before it is shown.

The app runs on Google Firebase (Auth, Firestore, Storage, Hosting, Functions). KFB-managed devices cannot load files from Firebase Storage, while every other part of Firebase works. To fix this with the smallest change, only Firebase Storage is replaced by a private S3 bucket. Everything else stays in Firebase.

S3 stores the photo files only.
Firestore stores the S3 object key, photo ID and status (Pending / Approved / Rejected). Approving a photo changes only Firestore.

The design was reviewed with the app owner, Cloud Ops and Security. Security approved the access model (Oct 12, 2026). The decision to use the L2 accounts was made Oct 22, 2026.

2. How it works
Access from Firebase to AWS (no AWS keys)

There are no AWS access keys anywhere. The app's Cloud Function proves who it is with a Google-signed token, and AWS swaps that for short-lived credentials.

The photo function runs as a dedicated Google service account (s3-files@events-ea237.iam.gserviceaccount.com).
It asks Google for an ID token with the agreed audience (kyfb-events-files).
It calls AWS STS AssumeRoleWithWebIdentity with that token and the role ARN.
STS checks the token and the role's trust policy, then returns temporary credentials (max 1 hour).
The AWS SDK in the function uses those credentials and refreshes them as needed.

The role's trust policy only accepts tokens where:

the issuer is Google (accounts.google.com),
aud and sub equal the service account's unique numeric ID, and
oaud equals the agreed audience.

No IAM OIDC provider resource is needed; AWS trusts Google natively.

A dedicated service account is used on purpose. The default Compute Engine account in the Google project is shared with other functions, and trusting it would give all of them access to the bucket.

Upload

User uploads -> function validates -> function assumes the role -> file is stored in S3 under photos/ -> Firestore gets the key and status Pending.

(Open: whether the function uploads the file itself, or returns a pre-signed PUT URL so the app uploads directly. The second option needs CORS; see cors_allowed_origins.)

Viewing

Function checks the viewer is allowed -> reads the S3 key from Firestore -> creates a pre-signed GET URL (short expiry, 5-15 minutes recommended) -> the browser loads the photo straight from S3.

Anyone holding a pre-signed URL can use it until it expires, so expiries are kept short.

3. What this repo creates (per environment)
Resource	Purpose
S3 bucket kfb-events-photos-<env>	Stores photo files
Public access block	All four settings on; bucket can never be public
Ownership controls	BucketOwnerEnforced - ACLs disabled
Encryption	SSE-S3 (AES256) by default; KMS if use_kms = true
Versioning	Off by default; on in prod (enable_versioning = true)
Lifecycle	Abort incomplete uploads after 7 days; expire old versions after 30 days when versioning is on
Bucket policy	Denies any request not using HTTPS
CORS (optional)	Only if cors_allowed_origins is set (direct browser upload)
IAM role kfb-events-s3-role-<env>	Assumed by the Google service account; 1-hour max session
IAM policy kfb-events-s3-role-policy-<env>	s3:PutObject, s3:GetObject, s3:DeleteObject on <bucket>/photos/* only

The role cannot list the bucket, change bucket settings or ACLs, or touch any other bucket or service.

Lifecycle note: there is deliberately no rule that expires all photos. Retention is a business decision for the app owner and will be added only once confirmed.

4. Repository layout
.github/workflows/
  tofu-plan.yml      Runs plan on every push (dev workspace) or on demand
  tofu-apply.yml     Runs apply on demand for a chosen workspace
envs/
  dev.tfvars         Values for the dev workspace
versions.tf          OpenTofu version, AWS provider pin, state backend, provider + tags
variables.tf         All input variables
s3.tf                Bucket and its settings
role.tf              IAM role, trust policy and permissions
README.md            This file
5. Environments

Each OpenTofu workspace has a matching envs/<workspace>.tfvars file and deploys to one L2 account.

Workspace	L2 account	GitHub environment	Status
dev	L2-Development	nonprod	Deployed Nov 9, 2026
prod	L2-Prod	prod (main branch only, reviewer approval)	Planned, before Dec 2, 2026
QA / UAT / Perf	L2-QA / L2-UAT / L2-Pre-Prod	nonprod	To be confirmed

Each environment's role trusts only that environment's Google service account.

6. How to deploy

All changes go through GitHub Actions. No console changes. Nothing needs to be run locally.

Plan

Every push to any branch runs tofu-plan against the dev workspace.
To plan another workspace: Actions -> tofu-plan -> Run workflow -> enter the workspace name.
The plan includes the OPA policy check.

Apply

Actions -> tofu-apply -> Run workflow -> choose the branch and enter the workspace (e.g. dev).
prod can only be applied from main and needs reviewer approval.

Normal change process

Create a branch, make the change, push.
Check the plan (and OPA) in Actions.
Open a PR, include the plan, get CPE review.
Merge and apply through the workflow.

Add a new environment

Create envs/<workspace>.tfvars (copy dev.tfvars and change the values).
Get that environment's Google service account unique ID from the app owner.
Run plan, then apply for the new workspace.
Send the app owner the handoff values (section 8).
7. Configuration
State and provider
State: S3 bucket kfb-github-terraform-state (us-east-1), key tf-aws-kfb-events-infra/terraform.tfstate. Each workspace is stored under its own path automatically.
AWS provider pinned to 6.68.0.
The workflow logs in to AWS through GitHub's web identity, and the provider then assumes kfb-terraform-assume-role in the account given by destination_account_id.
Required KFB tags are applied to every resource via default_tags in versions.tf.
Variables
Variable	Required	Default	Meaning
environment	yes	dev	Used in bucket and role names
destination_account_id	yes	-	L2 account to deploy into
google_sa_unique_id	yes	-	Unique numeric ID of the app's Google service account
token_audience	yes	-	Audience the function requests on its Google ID token
object_prefix	no	photos/	Folder the role can use
allow_delete	no	true	Allow the role to delete photos
enable_versioning	no	false	Keep old versions (set true in prod)
noncurrent_version_days	no	30	Days to keep old versions
use_kms	no	false	Use KMS instead of SSE-S3
kms_key_arn	no	null	KMS key, only when use_kms = true
cors_allowed_origins	no	[]	Web domains allowed to upload directly from a browser

Do not put secrets in tfvars or tags. None are needed.

8. Handoff to the app owner (per environment)

Send these values - none of them are secret:

Bucket name
Region (us-east-1)
Role ARN
Object prefix (photos/)
Token audience
9. Acceptance tests
#	Test	Expected
T1	Unsigned or HTTP request to an object	Denied
T2	Function assumes the role with the approved service account	Credentials returned
T3	Different service account or wrong audience	AccessDenied
T4	Role actions inside photos/ vs outside / other buckets	Inside allowed, outside denied
T5	Upload, then view via pre-signed URL	Works, encrypted, Firestore = Pending
T6	Load a photo from a KFB-managed device	Displays (proves the fix)
T7	Expired URL	Denied

T1-T4 are run by CPE; T5-T7 together with the app owner.

10. Ownership
Area	Owner
This repo and the design	Cloud Platform Engineering (CPE) - Sai Praneeth
Bucket operations (security, lifecycle, monitoring)	Cloud Ops
Photo data, retention, deleting files when photos are rejected	App owner - Adam Rayborn
11. Open items
Upload method: function uploads vs pre-signed PUT URL (CORS needed for the second).
Retention after the Annual Meeting (Dec 2, 2026).
Whether delete/reject removes the S3 file (drives allow_delete).
Separate Google service account for prod.
SSE-S3 vs KMS, URL expiry and logging ownership (Security).
Object-level logging (CloudTrail data events or S3 access logs) - not yet in this repo.
Outputs (bucket name, Region, role ARN) - not yet in this repo.
Tag values for requested_by and business_ops_category.
Workflows use tf-action-tooling@main and tofu_version: latest; the IaC standard says to pin to a release tag and fixed version.
Confirm KFB-managed devices can reach kfb-events-photos-<env>.s3.us-east-1.amazonaws.com (root cause of the original block is not confirmed).
12. Related documents
Design: Firebase_to_S3_Design.docx (CPE SharePoint: Work in Progress / Proposals + Designs)
Policy JSON and approvals: Jira HC-77160
