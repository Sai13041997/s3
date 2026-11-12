PS C:\Users\T012sp\Git repo\tf-aws-kfb-events-infra> Get-Content READMe.md
# tf-aws-kfb-events-infra

OpenTofu code for the AWS side of the **KFB Events photo app**: one private S3 bucket and one IAM role per environment, deployed into the L2 accounts.


The Events app (built and owned by Adam Rayborn, outside core KFB systems) lets people upload event photos from mobile and web. KFB staff review each photo and approve or delete it before it is shown.

The app runs on Google Firebase (Auth, Firestore, Storage, Hosting, Functions). KFB-managed devices cannot load files from Firebase Storage, while every other part of Firebase works. To fix this with the smallest change, **only Firebase Storage is replaced by a private S3 bucket**. Everything else stays in Firebase.

- **S3** stores the photo files only.
- **Firestore** stores the S3 object key, photo ID and status (Pending / Approved / Rejected). Approving a photo changes only Firestore.

The design was reviewed with the app owner, Cloud Ops and Security. Security approved the access model (Oct 12, 2026). The decision to use the L2 accounts was made Oct 22, 2026.

---

## How it works

### Access from Firebase to AWS (no AWS keys)

There are **no AWS access keys anywhere**. The app's Cloud Function proves who it is with a Google-signed token, and AWS swaps that for short-lived credentials.

1. The photo function runs as a dedicated Google service account (`s3-files@events-ea237.iam.gserviceaccount.com`).
2. It asks Google for an ID token with the agreed audience (`kyfb-events-files`).
3. It calls AWS STS `AssumeRoleWithWebIdentity` with that token and the role ARN.
4. STS checks the token and the role's trust policy, then returns temporary credentials (max 1 hour).
5. The AWS SDK in the function uses those credentials and refreshes them as needed.

The role's trust policy only accepts tokens where:
- the issuer is Google (`accounts.google.com`),
- `aud` and `sub` equal the service account's unique numeric ID, and
- `oaud` equals the agreed audience.

No IAM OIDC provider resource is needed; AWS trusts Google natively.

> A dedicated service account is used on purpose. The default Compute Engine account in the Google project is shared with other functions, and trusting it would give all of them access to the bucket.

### Upload

User uploads -> function validates -> function assumes the role -> file is stored in S3 under `photos/` -> Firestore gets the key and status `Pending`.

(Open: whether the function uploads the file itself, or returns a pre-signed PUT URL so the app uploads directly. The second option needs CORS; see `cors_allowed_origins`.)

### Viewing

Function checks the viewer is allowed -> reads the S3 key from Firestore -> creates a pre-signed GET URL (short expiry, 5-15 minutes recommended) -> the browser loads the photo straight from S3.

Anyone holding a pre-signed URL can use it until it expires, so expiries are kept short.

---

## What this repo creates (per environment)

| Resource | Purpose |
|---|---|
| S3 bucket `kfb-events-photos-<env>` | Stores photo files |
| Public access block | All four settings on; bucket can never be public |
| Ownership controls | `BucketOwnerEnforced` - ACLs disabled |
| Encryption | SSE-S3 (AES256) by default; KMS if `use_kms = true` |
| Versioning | Off by default; on in prod (`enable_versioning = true`) |
| Lifecycle | Abort incomplete uploads after 7 days; expire old versions after 30 days when versioning is on |
| Bucket policy | Denies any request not using HTTPS |
| CORS (optional) | Only if `cors_allowed_origins` is set (direct browser upload) |
| IAM role `kfb-events-s3-role-<env>` | Assumed by the Google service account; 1-hour max session |
| IAM policy `kfb-events-s3-role-policy-<env>` | `s3:PutObject`, `s3:GetObject`, `s3:DeleteObject` on `<bucket>/photos/*` only |

The role cannot list the bucket, change bucket settings or ACLs, or touch any other bucket or service.

**Lifecycle note:** there is deliberately **no rule that expires all photos**. Retention is a business decision for the app owner and will be added only once confirmed.

---

## Repository layout

```
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
```

---

## Related documents

- Design: `Firebase_to_S3_Design.docx` (CPE SharePoint: Work in Progress / Proposals + Designs)
PS C:\Users\T012sp\Git repo\tf-aws-kfb-events-infra> 
