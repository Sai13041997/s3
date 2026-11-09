Project Handoff: Firebase Storage to AWS S3 (Photo File Backend)
1. My role and how I like to work
Me: Sai Praneeth, Cloud Engineer III (contractor), Cloud Platform Engineering (CPE) at KFB. Manager: Phillip Williams.
My responsibility:
Owner of the design.
I am now also building the infrastructure (IaC) in a GitHub repo that already exists for the L2 accounts. The repo's basic setup is done.
How I like to work:
Simple, plain-English explanations, one topic at a time, step by step.
When learning Terraform/OpenTofu, give the code together with an explanation.
Short, copy-paste-ready messages for teammates.
Design documents short (3–4 pages) and with no code.
2. People involved
Person	Role in this projectAdam Rayborn	Owner and developer of the Firebase app (a Federation application, outside core KFB systems). On Oct 7 he said his side is ready and he only needs the bucket name, Region, and role ARN.
Phillip Williams	My manager. On Nov 4 he moved HC-77160 to the Cloud Ops team, assigned it to Mike Martinez, and noted he asked me to look at it.
Mike Martinez	Current Jira assignee for HC-77160 (Cloud Ops).
John Van Sickle (JVS)	Asked about doing this in GCP or behind an approved domain. Satisfied with our answer.
Jeff McMahon	Organized the requirements review meeting.
Alex Schoborg	CPE colleague. Has the design doc link.
CloudOps team	Asked about lifecycle, retention, and who owns the bucket.
3. Work items, timeline, and approvals
Jira:
HC-77160 (Help Center), now with Cloud Ops, assignee Mike Martinez.
CPE-296 (Cloud Platform Engineering).
Both titled "Need help in moving from Google Firebase to AWS S3 for website file backend."
Deadline: the app is for the KFB Annual Meeting on December 2. Adam needs to test before then.
Security: per my Oct 12 Teams message, the proposed process is documented in the ticket and was approved by the security team.
Decision (Oct 22): the S3 bucket will be deployed in the L2 accounts.
4. The application
Users upload event photos from mobile and web apps. KFB staff review each photo and approve or delete it before it is shown to users.
Two user types:
Non-KFB users, who upload photos.
KFB staff on KFB-managed devices, who review them.
Current stack (all Google Firebase):
Authentication and Anonymous Authentication
Firestore
Storage
Hosting
Functions
Current flow: upload → Firebase Storage stores the file → Firestore stores the reference and "Pending" status → staff review → approve or delete → approved photos are visible.
5. The problem
KFB-managed devices cannot reach Firebase Storage, so staff cannot load, approve, or delete photos. Everything else in Firebase works.
The root cause is not confirmed. Suspected causes:
A web filter or proxy blocking Google storage domains.
A DLP policy.
SSL inspection.
Less likely: Firebase rules or CORS.
Risk: a broad cloud-storage filter could also block S3. Test T6 (load a photo on a KFB device) must prove access works.
6. Decisions made
6.1 Approach
Replace only Firebase Storage with a private S3 bucket. Everything else stays in Firebase. The whole app is not moving to AWS.
Reason: it is the smallest change, only storage is broken, and Adam wanted minimal change.
6.2 Where data lives
S3: photo files only.
Firestore:
S3 object key
Photo ID
Approval status (Pending, Approved, or Rejected)
When staff approve a photo, only the Firestore status changes. The file stays in S3.
6.3 Firebase-to-AWS access (no stored keys)
No AWS access keys are ever created or stored. Adam asked for an IAM role his Cloud Functions can assume.
Flow:
The Firebase Function runs as a Google service account and gets a Google-signed ID token.
It calls STS AssumeRoleWithWebIdentity with the token and the role ARN.
STS validates the token and checks the role's trust policy.
STS returns temporary credentials.
The function uses them through the AWS SDK and refreshes them when they expire.
Trust policy:
Federated principal: accounts.google.com.
Conditions pin accounts.google.com:aud and accounts.google.com:sub to the service account's unique numeric ID, and accounts.google.com:oaud to the agreed token audience.
No IAM OIDC provider resource is needed, because Google is a built-in AWS identity provider.
Maximum session duration: 1 hour.
Only the Firebase Function talks to AWS. Users never get AWS credentials.
6.4 Upload flow
The user uploads a photo.
The function validates it.
The function assumes the role and receives temporary credentials.
The function puts the file into S3 under photos/.
The S3 key and "Pending" status are saved in Firestore.

Open: Adam must confirm the upload method.

Option A (in the design): the function uploads the file.
Option B: the function returns a pre-signed PUT URL and the app uploads directly. IAM is the same, but CORS is needed for browser uploads. Adam's own diagram suggested Option B.
6.5 Viewing flow
A user or staff member opens a photo. The flow is the same for both.
The function checks permission.
The function reads the S3 key from Firestore.
The function uses valid credentials.
The AWS SDK signs a pre-signed GET URL for that one photo.
The client (browser or mobile app) loads the photo directly from S3.
S3 checks the signature and expiry, then returns the photo or Access Denied.

Pre-signed URL facts:

Each photo gets its own URL.
Recommended expiry: 5–15 minutes.
Anyone holding the URL can use it until it expires.
The URL dies at the earlier of its own expiry and the expiry of the credentials that signed it.
6.6 AWS resources (one bucket and one role per environment, in L2 accounts)
S3 bucket:
All Block Public Access settings on
ACLs disabled (BucketOwnerEnforced)
SSE-S3 encryption, or KMS if Security requires it
Versioning on in production
Static website hosting off
Bucket policy denies non-TLS requests
CORS only if Option B is used from a browser
IAM role permissions:
s3:PutObject, s3:GetObject, and s3:DeleteObject on <bucket>/photos/* only. Remove delete if the app never deletes.
No ListBucket, no ACL or bucket-setting changes, no other buckets or services.
If KMS is used, add kms:GenerateDataKey and kms:Decrypt on that one key.
Environment separation: each environment's role trusts only that environment's service account.
Logging:
CloudTrail management events.
Object-level access through CloudTrail data events or S3 access logs.
Tags: all required tags from the KFB Tag Dictionary. No PII or secrets in tag values.
6.7 Lifecycle and retention (ownership split)
CloudOps owns the bucket: security, lifecycle rules, monitoring.
The app owns the data:
Adam's app must delete the S3 file, not only the Firestore record, when staff delete a photo.
The business/app owner decides how long approved photos are kept.
Safe lifecycle rules now:
Abort incomplete multipart uploads after 7 days.
Expire old (noncurrent) versions after about 30 days if versioning is on.
Do NOT add "expire all photos after X" until Adam confirms. Otherwise Firestore would point to deleted files.
7. Implementation (NEW: I am building it)
7.1 Repository
Platform: a GitHub repo with OpenTofu, already created for the L2 accounts. Basic setup (structure, workflow, backend) is done.
Repo name: <REPO_NAME> (fill in).
KFB IaC standard to follow:
Shared tf-action-tooling workflow pinned to a release tag.
OPA policy checks in the plan stage.
Remote state in kfb-github-terraform-state (us-east-1), key per repo and workspace.
Workspaces with matching envs/<workspace>.tfvars files and GitHub environments.
Pin AWS provider versions.
No manual console changes.
README: link the design doc. Describe purpose, resources, environments, and deployment.
7.2 Target L2 accounts (from the KFB account mapping)
KFB environment	L2 accountDev	L2-Development
QA	L2-QA
UAT	L2-UAT
Perf	L2-Pre-Prod
Production	L2-Prod

Plan:

Build L2-Development first so Adam can test.
Then L2-Prod before December 2.

Whether QA, UAT, or Pre-Prod environments are needed is still to confirm.

7.3 What to add to the repo
S3 bucket with:
Public access block
Ownership controls
Encryption
Versioning (prod)
Lifecycle rules (section 6.7)
TLS-deny bucket policy
Optional CORS (Option B only).
IAM role with the web-identity trust policy (section 6.3) and the permissions policy (section 6.6).
Logging settings.
Tags (provider default_tags preferred).
Outputs: bucket name, Region, role ARN.

Variables per environment:

Bucket name
Role name
Google service account unique ID
Token audience
Object prefix
Whether delete is allowed
CORS origins
KMS on or off
7.4 Process
Branch, then PR with plan and OPA checks, then CPE review, then merge and apply through the workflow.
Run tests T1–T4 alone. Run T5–T7 with Adam.
Send the outputs to Adam.
Update both Jira items.
8. Meeting Q&A

Why not keep Firebase Storage? Staff can't reach it. This is the smallest fix.

Why not move everything to AWS? Only storage is broken. Moving everything is higher risk.

JVS: GCP, or an approved domain? We kept S3, for these reasons:

The review page already loads; only the photos, served from Google's shared storage domain, are blocked.
Allowlisting that domain opens every Google bucket, not just Adam's. S3 lets us allow only our bucket, under KFB AWS controls.
Adam has already built the S3 side, so switching risks the December 2 date.

Caveat: this assumes a root cause we haven't confirmed.

9. Inputs still needed

From Adam (critical items are #2 and #3; wrong values cause Access Denied):

Service account email.
Service account unique numeric ID (GCP: IAM & Admin → Service Accounts).
Token audience.
Whether non-production and production use separate service accounts.
S3 actions needed.
Folder path (default photos/).
Upload method (Option A or B). If B from a browser, his web domain.
Whether delete or reject removes the S3 file.
How long to keep photos after the Annual Meeting.

Internal:

Repo name.
Final bucket and role names.
Tag values.
Region (likely us-east-1, to confirm).
Which L2 environments to build.

Security:

SSE-S3 or KMS.
URL expiry.
Logging ownership.

Network:

The root cause of the block.
Confirmation that KFB devices can reach <bucket>.s3.<region>.amazonaws.com.
10. Handoff to Adam (per environment, no secrets)
Bucket name
Region
Role ARN
Object prefix
Token audience
11. Acceptance tests
#	Test	ExpectedT1	Unsigned or HTTP request to an object	Denied
T2	Function assumes the role with the approved service account	Credentials returned
T3	Same call with a different service account or wrong audience	AccessDenied
T4	Role actions inside photos/ vs. outside or other buckets	Inside allowed, outside denied
T5	Upload, then view with a pre-signed URL	Works, encrypted, Firestore = Pending
T6	Load a photo from a KFB-managed device	Displays (proves the fix)
T7	Use an expired URL	Denied
12. Documents
Firebase Storage to AWS S3 Migration.docx: the original investigation (September).
Meeting design docs (v1–v3): four diagrams with talking points.
21-page CloudOps detailed design: rejected, too long.
Current design doc: Firebase_to_S3_Design.docx (4 pages, no code). Stored in the CPE "Work in Progress/Proposals+Designs" SharePoint folder and shared with Alex. Retention is still listed as an open decision.
To do:
Add the lifecycle/ownership split and the L2 decision to the doc.
Keep policy JSON examples on the Jira ticket, not in the doc.
13. Next steps
Send Adam the questions in section 9.
Confirm S3 reachability from KFB devices with the network team.
Reply to CloudOps with the lifecycle/ownership split.
Add the resources in section 7.3 to the L2 repo and open a PR for L2-Development.
Apply, run T1–T4, send outputs to Adam, then run T5–T7 together.
Repeat for L2-Prod before December 2. Update HC-77160 and CPE-296.
