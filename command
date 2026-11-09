PS C:\Users\T012sp\Git repo\real-time-insurance-infra\.terraform> cd "C:\Users\T012sp\Git repo\real-time-insurance-infra"
>> Get-ChildItem -Recurse -Filter *.tf | Where-Object { $_.FullName -notmatch '\\.terraform\\' -and (Select-String -Path $_.FullName -Pattern 'required_providers|backend "s3"' -Quiet) } | ForEach-Object { "===== $($_.Name) ====="; Get-Content $_.FullName -Raw }
===== main.tf =====
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 6.68.0"
    }
  }
  backend "s3" {
    bucket = "kfb-github-terraform-state"
    key    = "real-time-insurance-infra/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::${var.destination_account_id}:role/kfb-terraform-assume-role"
  }
  default_tags {
    tags = {
      "application_name"      = "realtimeinsurance"
      "terraform"             = "true"
      "source"                = "github.com/kfbmic/real-time-insurance-infra"
      "created_by"            = "PlatformEngineering@kyfb.com"
      "requested_by"          = "PMOGroup@kyfb.com"
      "owned_by"              = "CloudOps@kyfb.com"
      "business_ops_category" = "POL"
    }
  }
}

provider "aws" {
  alias  = "networkaccount"
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::988597495512:role/kfb-terraform-assume-role"
  }
  default_tags {
    tags = {
      "application_name"      = "realtimeinsurance"
      "terraform"             = "true"
      "source"                = "github.com/kfbmic/real-time-insurance-infra"
      "created_by"            = "PlatformEngineering@kyfb.com"
      "requested_by"          = "PMOGroup@kyfb.com"
      "owned_by"              = "CloudOps@kyfb.com"
      "business_ops_category" = "POL"
    }
  }
}
import {
  to = module.policy_graph_ingest_lambda.aws_cloudwatch_log_group.this[0]
  id = "/aws/lambda/realtimeinsurance-dev-policy-graph-ingest-lambda"
}

import {
  to = module.soap_verification_lambda.aws_cloudwatch_log_group.this[0]
  id = "/aws/lambda/realtimeinsurance-dev-soap-verification-lambda"
}

PS C:\Users\T012sp\Git repo\real-time-insurance-infra>
