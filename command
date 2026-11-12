# tf-aws-kfb-events-infra

OpenTofu code for the AWS side of the **KFB Events app**: one private S3 bucket and one IAM role per environment, deployed into the L2 accounts.


The Events app (built and owned by Adam Rayborn, outside core KFB systems) lets people upload event photos from mobile and web. KFB staff review each photo and approve or delete it before it is shown. Staff can also upload resource files such as PDFs and presentations.

The app runs on Google Firebase (Auth, Firestore, Storage, Hosting, Functions). KFB-managed devices cannot load files from Firebase Storage, while every other part of Firebase works. To fix this with the smallest change, **only Firebase Storage is replaced by a private S3 bucket**. Everything else stays in Firebase.

- **S3** stores the files only: photos in `photos/`, staff resource files in `resources/`.
- **Firestore** stores the S3 object key, file ID and status (Pending / Approved / Rejected). Approving a photo changes only Firestore.

The design was reviewed with the app owner, Cloud Ops and Security. Security approved the access model (Oct 12, 2026). The decision to use the L2 accounts was made Oct 22, 2026.

---

## How it works

### Access from Firebase to AWS (no AWS keys)

There are **no AWS access keys anywhere**. The app's Cloud Function proves who it is with a Google-signed token, and AWS swaps that for short-lived credentials.

1. The function runs as a dedicated Google service account, one per environment:
   - dev: `s3-files@events-ea237.iam.gserviceaccount.com`
   - prod: `s3-files-prod@events-ea237.iam.gserviceaccount.com`
2. It asks Google for an ID token with the agreed audience (`kyfb-events-files`).
3. It calls AWS STS `AssumeRoleWithWebIdentity` with that token and the role ARN.
4. STS checks the token and the role's trust policy, then returns temporary credentials (max 1 hour).
5. The AWS SDK in the function uses those credentials and refreshes them as needed.

The role's trust policy only accepts tokens where:
- the issuer is Google (`accounts.google.com`),
- `aud` and `sub` equal that environment's service account unique numeric ID, and
- `oaud` equals the agreed audience.

No IAM OIDC provider resource is needed; AWS trusts Google natively.

> Dedicated service accounts are used on purpose. The default Compute Engine account in the Google project is shared with other functions, and dev and prod use separate accounts so dev or test code can never reach prod files.

### Upload

The function checks the user, then creates a pre-signed POST. The browser uploads the file straight to S3 as a multipart form. Photos go to `photos/`; staff resource files go to `resources/`, and the app only issues `resources/` uploads to staff. Firestore gets the key and status `Pending`.

### Viewing

Function checks the viewer is allowed -> reads the S3 key from Firestore -> creates a pre-signed GET URL (short expiry, 5-15 minutes recommended) -> the browser loads the file straight from S3 with `<img>` or `fetch`.

Anyone holding a pre-signed URL can use it until it expires, so expiries are kept short.

---

## What this repo creates (per environment)

| Resource | Purpose |
|---|---|
| S3 bucket `kfb-events-photos-<env>` | Stores the app's files |
| Public access block | All four settings on; bucket can never be public |
| Ownership controls | `BucketOwnerEnforced` - ACLs disabled |
| Encryption | SSE-S3 (AES256) by default; KMS if `use_kms = true` |
| Lifecycle | Abort incomplete uploads after 7 days |
| Bucket policy | Denies any request not using HTTPS |
| CORS | GET, HEAD and POST from the app's web origins only; Content-Type header only |
| IAM role `kfb-events-s3-role-<env>` | Assumed by that environment's Google service account; 1-hour max session |
| IAM policy `kfb-events-s3-role-policy-<env>` | Get, put and delete on `photos/*` and `resources/*`; list only those folders |

The role can list only keys in its folders. It cannot change bucket settings or ACLs, or touch any other bucket or service.

**Versioning is off.** The data isn't business-critical and the app manages its own files, so deleted or overwritten files are not kept. The app owner can request versioning with a justification.

**Lifecycle note:** there is deliberately **no rule that expires files**. Retention is a business decision for the app owner and will be added only once confirmed.

---

## Repository layout

```
.github/workflows/
  tofu-plan.yml      Runs plan on every push (dev workspace) or on demand
  tofu-apply.yml     Runs apply on demand for a chosen workspace
envs/
  dev.tfvars         Values for the dev workspace
  prod.tfvars        Values for the prod workspace
versions.tf          OpenTofu version, AWS provider pin, state backend, provider + tags
variables.tf         All input variables
s3.tf                Bucket and its settings
role.tf              IAM role, trust policy and permissions
README.md            This file
```

---

## Related documents

- Design: `Firebase_to_S3_Design.docx` (CPE SharePoint: Work in Progress / Proposals + Designs)
