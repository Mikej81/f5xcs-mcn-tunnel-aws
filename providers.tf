terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    volterrarm = {
      source  = "volterraedge/volterra"
      version = "0.11.3"
    }
    http = {
      source  = "hashicorp/http"
      version = "2.1.0"
    }
  }
}
provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  #token      = var.aws_session_token
  region = var.aws_region
}
provider "volterrarm" {
  api_p12_file = var.api_p12_file
  api_cert     = var.api_p12_file != "" ? "" : var.api_cert
  api_key      = var.api_p12_file != "" ? "" : var.api_key
  url          = var.api_url
}

provider "http" {
}
