versions.tf:


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
    key    = "tf-aws-kfb-events-infra/terraform.tfstate"
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
      "application_name"      = "kfbevents"
      "terraform"             = "true"
      "source"                = "github.com/kfbmic/tf-aws-kfb-events-infra"
      "created_by"            = "PlatformEngineering@kyfb.com"
      "requested_by"          = "TODO"
      "owned_by"              = "CloudOps@kyfb.com"
      "business_ops_category" = "TODO"
    }
  }
}
