PS C:\Users\T012sp\Git repo\real-time-insurance-infra> cd .\.terraform\
PS C:\Users\T012sp\Git repo\real-time-insurance-infra\.terraform> ls 


    Directory: C:\Users\T012sp\Git repo\real-time-insurance-infra\.terraform


Mode                 LastWriteTime         Length Name                                                                                                                                                       
----                 -------------         ------ ----                                                                                                                                                       
d-----        10/26/2026   9:09 AM                modules                                                                                                                                                    
d-----          9/2/2026  11:48 AM                providers                                                                                                                                                  
-a----         9/14/2026   5:02 PM              7 environment                                                                                                                                                
-a----          9/2/2026  11:48 AM           2496 terraform.tfstate                                                                                                                                          


PS C:\Users\T012sp\Git repo\real-time-insurance-infra\.terraform>PS C:\Users\T012sp\Git repo\tf-aws-kfb-events-infra> Get-ChildItem -Recurse -File | ForEach-Object { "===== $($_.FullName.Substring((Get-Location).Path.Length + 1)) ====="; Get-Content $_.FullName -Raw }
===== README.md =====
# tf-aws-kfb-events-infra

## Purpose
KFB Events OpenTofu deployment repository


## Environments
This repository is configured with two deployment environments:
- `nonprod` â€” no branch or reviewer restrictions.
- `prod` â€” restricted to the `main` branch and requires reviewer approval.


## How To Plan/Apply
*{Document how to run `tofu plan` and `tofu apply` locally and via CI for this project, including required credentials/roles.}*


## State Backend
*{Document the state backend (bucket/key/region or equivalent) used by this project.}*


## Ownership
*{Team or individuals responsible for this infrastructure.}*

===== role.tf =====
resource "aws_iam_role" "s3_role" {
  name               = "kfb-events-s3-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.s3_role_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "s3_role_policy" {
  role       = aws_iam_role.s3_role.name
  policy_arn = aws_iam_policy.s3_role_policy.arn
}

resource "aws_iam_policy" "s3_role_policy" {
  name   = "kfb-events-s3-role-policy-${var.environment}"
  policy = data.aws_iam_policy_document.s3_role_policy.json
}

data "aws_iam_policy_document" "s3_role_assume_role_policy" {
  TBD TBD TBD TBD
}

data "aws_iam_policy_document" "s3_role_policy" {
  statement {
    sid = "S3Access"
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    effect    = "Allow"
    resources = ["arn:aws:s3:::kfb-events-photos-${var.environment}/*"]
  }
}
===== s3.tf =====
resource "aws_s3_bucket" "github_tf_state" {
  bucket   = "kfb-events-photos-${var.environment}"
}

resource "aws_s3_bucket_public_access_block" "github_tf_state_access" {
  bucket                  = aws_s3_bucket.github_tf_state.id
  ignore_public_acls      = true
  restrict_public_buckets = true
  block_public_acls       = true
  block_public_policy     = true
}


===== variables.tf =====
variable "environment" {
  type        = string
  description = "Environment to deploy into."
  default     = "dev"
}
===== .github\workflows\tofu-apply.yml =====
name: tofu-apply

on:
  workflow_dispatch:
    inputs:
      workspace:
        description: "Workspace to apply (must match envs/<workspace>.tfvars)"
        required: true
        type: string

permissions:
  id-token: write
  contents: read

jobs:
  apply:
    uses: kfbmic/tf-action-tooling/.github/workflows/tofu-apply-aws.yml@main
    with:
      terraform_directory: .
      aws_region: us-east-1
      tofu_version: latest
      use_workspaces: true
      workspace: ${{ inputs.workspace }}
      # Map workspace name directly to GitHub Environment name
      environment_name: ${{ inputs.workspace == 'prod' && 'prod' || 'nonprod' }}
    secrets:
      aws_tofu_role_arn: ${{ secrets.AWS_TOFU_ROLE_ARN }}
      cross_repo_app_id: ${{ secrets.CROSS_REPO_APP_ID }}
      cross_repo_key: ${{ secrets.CROSS_REPO_KEY }}
===== .github\workflows\tofu-plan.yml =====
name: tofu-plan

on:
  push:
  workflow_dispatch:
    inputs:
      workspace:
        description: "Workspace to plan (must match envs/<workspace>.tfvars). Defaults to dev."
        required: false
        type: string
        default: dev

permissions:
  id-token: write
  contents: read

jobs:
  plan:
    uses: kfbmic/tf-action-tooling/.github/workflows/tofu-plan-aws.yml@main
    with:
      terraform_directory: .
      aws_region: us-east-1
      tofu_version: latest
      use_workspaces: true
      # Use dev workspace/environment for push, otherwise use the selected workspace name.
      workspace: ${{ github.event_name == 'push' && 'dev' || inputs.workspace }}
      environment_name: ${{ inputs.workspace == 'prod' && 'prod' || 'nonprod' }}
      run_fmt: false
      run_validate: false
      init_upgrade: true
      # OPA policy validation is not yet enabled for this repo.
      include_opa_check: true
    secrets:
      aws_tofu_role_arn: ${{ secrets.AWS_TOFU_ROLE_ARN }}
      cross_repo_app_id: ${{ secrets.CROSS_REPO_APP_ID }}
      cross_repo_key: ${{ secrets.CROSS_REPO_KEY }}
PS C:\Users\T012sp\Git repo\tf-aws-kfb-events-infra> 
