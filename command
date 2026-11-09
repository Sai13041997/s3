Run set +e
  set +e
  test -f "envs/dev.tfvars" || { echo "ERROR: Missing tfvars file: envs/dev.tfvars"; exit 1; }
  tofu plan -no-color -var-file="envs/dev.tfvars" -out=tfplan &> tofu_plan_stdout
  tofu_plan_exit_code="$?"
  cat tofu_plan_stdout
  if [[ "$tofu_plan_exit_code" -ne 0 ]]; then
      grep -i Error tofu_plan_stdout || true
      echo "OpenTofu plan failed"
      exit 1
  fi
      
  shell: /usr/bin/bash --noprofile --norc -e -o pipefail {0}
  env:
    TF_IN_AUTOMATION: true
    TF_INPUT: false
    AWS_DEFAULT_REGION: us-east-1
    AWS_REGION: us-east-1
    AWS_ACCESS_KEY_ID: ***
    AWS_SECRET_ACCESS_KEY: ***
    AWS_SESSION_TOKEN: ***
    TOFU_CLI_PATH: /home/runner/work/_temp/48b7dd48-90c0-43bc-aeff-808131a01f4b
data.aws_iam_policy_document.s3_role_assume_role_policy: Reading...
data.aws_iam_policy_document.s3_role_assume_role_policy: Read complete after 0s [id=1565459790]

OpenTofu used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create
 <= read (data resources)

OpenTofu will perform the following actions:

  # data.aws_iam_policy_document.photos_bucket will be read during apply
  # (config refers to values not yet known)
 <= data "aws_iam_policy_document" "photos_bucket" {
      + id            = (known after apply)
      + json          = (known after apply)
      + minified_json = (known after apply)

      + statement {
          + actions   = [
              + "s3:*",
            ]
          + effect    = "Deny"
          + resources = [
              + (known after apply),
              + (known after apply),
            ]
          + sid       = "DenyNonTLS"

          + condition {
              + test     = "Bool"
              + values   = [
                  + "false",
                ]
              + variable = "aws:SecureTransport"
            }

          + principals {
              + identifiers = [
                  + "*",
                ]
              + type        = "*"
            }
        }
    }

  # data.aws_iam_policy_document.s3_role_policy will be read during apply
  # (config refers to values not yet known)
 <= data "aws_iam_policy_document" "s3_role_policy" {
      + id            = (known after apply)
      + json          = (known after apply)
      + minified_json = (known after apply)

      + statement {
          + actions   = [
              + "s3:DeleteObject",
              + "s3:GetObject",
              + "s3:PutObject",
            ]
          + effect    = "Allow"
          + resources = [
              + (known after apply),
            ]
          + sid       = "PhotoObjectsOnly"
        }
    }

  # aws_iam_policy.s3_role_policy will be created
  + resource "aws_iam_policy" "s3_role_policy" {
      + arn              = (known after apply)
      + attachment_count = (known after apply)
      + id               = (known after apply)
      + name             = "kfb-events-s3-role-policy-dev"
      + name_prefix      = (known after apply)
      + path             = "/"
      + policy           = (known after apply)
      + policy_id        = (known after apply)
      + tags_all         = {
          + "application_name"      = "kfbevents"
          + "business_ops_category" = "TODO"
          + "created_by"            = "PlatformEngineering@kyfb.com"
          + "owned_by"              = "CloudOps@kyfb.com"
          + "requested_by"          = "TODO"
          + "source"                = "github.com/kfbmic/tf-aws-kfb-events-infra"
          + "terraform"             = "true"
        }
    }

  # aws_iam_role.s3_role will be created
  + resource "aws_iam_role" "s3_role" {
      + arn                   = (known after apply)
      + assume_role_policy    = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "sts:AssumeRoleWithWebIdentity"
                      + Condition = {
                          + StringEquals = {
                              + "accounts.google.com:aud"  = "113890604168937748514"
                              + "accounts.google.com:oaud" = "kyfb-events-files"
                              + "accounts.google.com:sub"  = "113890604168937748514"
                            }
                        }
                      + Effect    = "Allow"
                      + Principal = {
                          + Federated = "accounts.google.com"
                        }
                      + Sid       = "AllowGoogleServiceAccount"
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + create_date           = (known after apply)
      + force_detach_policies = false
      + id                    = (known after apply)
      + managed_policy_arns   = (known after apply)
      + max_session_duration  = 3600
      + name                  = "kfb-events-s3-role-dev"
      + name_prefix           = (known after apply)
      + path                  = "/"
      + tags_all              = {
          + "application_name"      = "kfbevents"
          + "business_ops_category" = "TODO"
          + "created_by"            = "PlatformEngineering@kyfb.com"
          + "owned_by"              = "CloudOps@kyfb.com"
          + "requested_by"          = "TODO"
          + "source"                = "github.com/kfbmic/tf-aws-kfb-events-infra"
          + "terraform"             = "true"
        }
      + unique_id             = (known after apply)

      + inline_policy (known after apply)
    }

  # aws_iam_role_policy_attachment.s3_role_policy will be created
  + resource "aws_iam_role_policy_attachment" "s3_role_policy" {
      + id         = (known after apply)
      + policy_arn = (known after apply)
      + role       = "kfb-events-s3-role-dev"
    }

  # aws_s3_bucket.photos will be created
  + resource "aws_s3_bucket" "photos" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = "kfb-events-photos-dev"
      + bucket_domain_name          = (known after apply)
      + bucket_namespace            = (known after apply)
      + bucket_prefix               = (known after apply)
      + bucket_region               = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + object_lock_enabled         = (known after apply)
      + policy                      = (known after apply)
      + region                      = "us-east-1"
      + request_payer               = (known after apply)
      + tags_all                    = {
          + "application_name"      = "kfbevents"
          + "business_ops_category" = "TODO"
          + "created_by"            = "PlatformEngineering@kyfb.com"
          + "owned_by"              = "CloudOps@kyfb.com"
          + "requested_by"          = "TODO"
          + "source"                = "github.com/kfbmic/tf-aws-kfb-events-infra"
          + "terraform"             = "true"
        }
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + cors_rule (known after apply)

      + grant (known after apply)

      + lifecycle_rule (known after apply)

      + logging (known after apply)

      + object_lock_configuration (known after apply)

      + replication_configuration (known after apply)

      + server_side_encryption_configuration (known after apply)

      + versioning (known after apply)

      + website (known after apply)
    }

  # aws_s3_bucket_lifecycle_configuration.photos will be created
  + resource "aws_s3_bucket_lifecycle_configuration" "photos" {
      + bucket                                 = (known after apply)
      + expected_bucket_owner                  = (known after apply)
      + id                                     = (known after apply)
      + region                                 = "us-east-1"
      + transition_default_minimum_object_size = "all_storage_classes_128K"

      + rule {
          + id     = "abort-incomplete-uploads"
          + status = "Enabled"

          + abort_incomplete_multipart_upload {
              + days_after_initiation = 7
            }

          + filter {
            }
        }
    }

  # aws_s3_bucket_ownership_controls.photos will be created
  + resource "aws_s3_bucket_ownership_controls" "photos" {
      + bucket = (known after apply)
      + id     = (known after apply)
      + region = "us-east-1"

      + rule {
          + object_ownership = "BucketOwnerEnforced"
        }
    }

  # aws_s3_bucket_policy.photos will be created
  + resource "aws_s3_bucket_policy" "photos" {
      + bucket = (known after apply)
      + id     = (known after apply)
      + policy = (known after apply)
      + region = "us-east-1"
    }

  # aws_s3_bucket_public_access_block.photos will be created
  + resource "aws_s3_bucket_public_access_block" "photos" {
      + block_public_acls       = true
      + block_public_policy     = true
      + bucket                  = (known after apply)
      + id                      = (known after apply)
      + ignore_public_acls      = true
      + region                  = "us-east-1"
      + restrict_public_buckets = true
    }

  # aws_s3_bucket_server_side_encryption_configuration.photos will be created
  + resource "aws_s3_bucket_server_side_encryption_configuration" "photos" {
      + bucket = (known after apply)
      + id     = (known after apply)
      + region = "us-east-1"

      + rule {
          + blocked_encryption_types = (known after apply)
          + bucket_key_enabled       = false

          + apply_server_side_encryption_by_default {
              + kms_master_key_id = (known after apply)
              + sse_algorithm     = "AES256"
            }
        }
    }

  # aws_s3_bucket_versioning.photos will be created
  + resource "aws_s3_bucket_versioning" "photos" {
      + bucket = (known after apply)
      + id     = (known after apply)
      + region = "us-east-1"

      + versioning_configuration {
          + mfa_delete = (known after apply)
          + status     = "Disabled"
        }
    }

Plan: 10 to add, 0 to change, 0 to destroy.
