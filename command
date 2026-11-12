Run set +e
aws_s3_bucket_versioning.photos: Refreshing state... [id=kfb-events-photos-dev]
data.aws_iam_policy_document.s3_role_assume_role_policy: Reading...
aws_s3_bucket.photos: Refreshing state... [id=kfb-events-photos-dev]
data.aws_iam_policy_document.s3_role_assume_role_policy: Read complete after 0s [id=1565459790]
aws_iam_role.s3_role: Refreshing state... [id=kfb-events-s3-role-dev]
aws_s3_bucket_cors_configuration.photos[0]: Refreshing state... [id=kfb-events-photos-dev]
aws_s3_bucket_public_access_block.photos: Refreshing state... [id=kfb-events-photos-dev]
aws_s3_bucket_ownership_controls.photos: Refreshing state... [id=kfb-events-photos-dev]
aws_s3_bucket_lifecycle_configuration.photos: Refreshing state... [id=kfb-events-photos-dev]
aws_s3_bucket_server_side_encryption_configuration.photos: Refreshing state... [id=kfb-events-photos-dev]
aws_iam_policy.s3_role_policy: Refreshing state... [id=arn:aws:iam::058264370150:policy/kfb-events-s3-role-policy-dev]
aws_s3_bucket_policy.photos: Refreshing state... [id=kfb-events-photos-dev]
aws_iam_role_policy_attachment.s3_role_policy: Refreshing state... [id=kfb-events-s3-role-dev/arn:aws:iam::058264370150:policy/kfb-events-s3-role-policy-dev]

OpenTofu used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  ~ update in-place (current -> planned)
  - destroy
 <= read (data resources)

OpenTofu will perform the following actions:

  # data.aws_iam_policy_document.photos_bucket will be read during apply
  # (depends on a resource or a module with changes pending)
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
              + "arn:aws:s3:::kfb-events-photos-dev",
              + "arn:aws:s3:::kfb-events-photos-dev/*",
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
  # (depends on a resource or a module with changes pending)
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
              + "arn:aws:s3:::kfb-events-photos-dev/photos/*",
              + "arn:aws:s3:::kfb-events-photos-dev/resources/*",
            ]
          + sid       = "AppFoldersOnly"
        }
      + statement {
          + actions   = [
              + "s3:ListBucket",
            ]
          + effect    = "Allow"
          + resources = [
              + "arn:aws:s3:::kfb-events-photos-dev",
            ]
          + sid       = "ListAppFoldersOnly"

          + condition {
              + test     = "StringLike"
              + values   = [
                  + "photos/*",
                  + "resources/*",
                ]
              + variable = "s3:prefix"
            }
        }
    }

  # aws_iam_policy.s3_role_policy will be updated in-place
  ~ resource "aws_iam_policy" "s3_role_policy" {
        id               = "arn:aws:iam::058264370150:policy/kfb-events-s3-role-policy-dev"
        name             = "kfb-events-s3-role-policy-dev"
      ~ policy           = jsonencode(
            {
              - Statement = [
                  - {
                      - Action   = [
                          - "s3:PutObject",
                          - "s3:GetObject",
                          - "s3:DeleteObject",
                        ]
                      - Effect   = "Allow"
                      - Resource = [
                          - "arn:aws:s3:::kfb-events-photos-dev/resources/*",
                          - "arn:aws:s3:::kfb-events-photos-dev/photos/*",
                        ]
                      - Sid      = "AppFoldersOnly"
                    },
                  - {
                      - Action    = "s3:ListBucket"
                      - Condition = {
                          - StringLike = {
                              - "s3:prefix" = [
                                  - "photos/*",
                                  - "resources/*",
                                ]
                            }
                        }
                      - Effect    = "Allow"
                      - Resource  = "arn:aws:s3:::kfb-events-photos-dev"
                      - Sid       = "ListAppFoldersOnly"
                    },
                ]
              - Version   = "2012-10-17"
            }
        ) -> (known after apply)
      ~ tags             = {
          - "business_ops_category" = "TODO" -> null
          - "requested_by"          = "TODO" -> null
        }
      ~ tags_all         = {
          ~ "business_ops_category" = "TODO" -> "FED"
          ~ "requested_by"          = "TODO" -> "FED"
            # (5 unchanged elements hidden)
        }
        # (4 unchanged attributes hidden)
    }

  # aws_iam_role.s3_role will be updated in-place
  ~ resource "aws_iam_role" "s3_role" {
        id                    = "kfb-events-s3-role-dev"
        name                  = "kfb-events-s3-role-dev"
      ~ tags                  = {
          - "business_ops_category" = "TODO" -> null
          - "requested_by"          = "TODO" -> null
        }
      ~ tags_all              = {
          ~ "business_ops_category" = "TODO" -> "FED"
          ~ "requested_by"          = "TODO" -> "FED"
            # (5 unchanged elements hidden)
        }
        # (8 unchanged attributes hidden)
    }

  # aws_s3_bucket.photos will be updated in-place
  ~ resource "aws_s3_bucket" "photos" {
        id                          = "kfb-events-photos-dev"
      ~ tags                        = {
          - "business_ops_category" = "TODO" -> null
          - "requested_by"          = "TODO" -> null
        }
      ~ tags_all                    = {
          ~ "business_ops_category" = "TODO" -> "FED"
          ~ "requested_by"          = "TODO" -> "FED"
            # (5 unchanged elements hidden)
        }
        # (12 unchanged attributes hidden)

        # (5 unchanged blocks hidden)
    }

  # aws_s3_bucket_cors_configuration.photos[0] will be updated in-place
  ~ resource "aws_s3_bucket_cors_configuration" "photos" {
        id     = "kfb-events-photos-dev"
        # (2 unchanged attributes hidden)

      - cors_rule {
          - allowed_headers = [
              - "*",
            ] -> null
          - allowed_methods = [
              - "GET",
              - "HEAD",
              - "POST",
            ] -> null
          - allowed_origins = [
              - "http://localhost:5173",
              - "https://events-ea237.firebaseapp.com",
              - "https://events-ea237.web.app",
              - "https://kfbeventstaff.com",
            ] -> null
          - expose_headers  = [] -> null
          - max_age_seconds = 3000 -> null
        }
      + cors_rule {
          + allowed_headers = [
              + "Content-Type",
            ]
          + allowed_methods = [
              + "GET",
              + "HEAD",
              + "POST",
            ]
          + allowed_origins = [
              + "http://localhost:5173",
              + "https://events-ea237.firebaseapp.com",
              + "https://events-ea237.web.app",
              + "https://kfbeventstaff.com",
            ]
          + expose_headers  = []
          + max_age_seconds = 3000
        }
    }

  # aws_s3_bucket_policy.photos will be updated in-place
  ~ resource "aws_s3_bucket_policy" "photos" {
        id     = "kfb-events-photos-dev"
      ~ policy = jsonencode(
            {
              - Statement = [
                  - {
                      - Action    = "s3:*"
                      - Condition = {
                          - Bool = {
                              - "aws:SecureTransport" = "false"
                            }
                        }
                      - Effect    = "Deny"
                      - Principal = "*"
                      - Resource  = [
                          - "arn:aws:s3:::kfb-events-photos-dev/*",
                          - "arn:aws:s3:::kfb-events-photos-dev",
                        ]
                      - Sid       = "DenyNonTLS"
                    },
                ]
              - Version   = "2012-10-17"
            }
        ) -> (known after apply)
        # (2 unchanged attributes hidden)
    }

  # aws_s3_bucket_versioning.photos will be destroyed
  # (because aws_s3_bucket_versioning.photos is not in configuration)
  - resource "aws_s3_bucket_versioning" "photos" {
      - bucket = "kfb-events-photos-dev" -> null
      - id     = "kfb-events-photos-dev" -> null
      - region = "us-east-1" -> null

      - versioning_configuration {
          - mfa_delete = "Disabled" -> null
          - status     = "Disabled" -> null
        }
    }

Plan: 0 to add, 5 to change, 1 to destroy.
