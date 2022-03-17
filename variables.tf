####################################
## Application Module - Variables ##
####################################

# Application definition

variable "name" {
  type        = string
  description = "Application name"
  default     = "titan"
}

variable "environment" {
  type        = string
  description = "Application environment"
  default     = "dev"
}

variable "adminUserName" {
  type        = string
  description = "REQUIRED: Admin Username for All systems"
  default     = "xadmin"
}

variable "sshPublicKey" {
  type        = string
  description = "OPTIONAL: ssh public key for instances"
  default     = ""
}
variable "sshPublicKeyPath" {
  type        = string
  description = "OPTIONAL: ssh public key path for instances"
  default     = "~/.ssh/id_rsa.pub"
}

#####################
## AWS Definitions ##
#####################
variable "aws_access_key" {
  type        = string
  description = "AWS access key"
  default     = "complete-thi"
}
variable "aws_secret_key" {
  type        = string
  description = "AWS secret key"
  default     = "complete-this"
}
variable "aws_session_token" {
  type    = string
  default = "complete-this"
}
variable "aws_region" {
  type        = string
  description = "REQUIRED: AWS region: us-east-1, us-west-1, ca-central-1, etc. For a list of available regions use `aws ec2 describe-regions`"
  default     = "ap-northeast-1"
}
# AWS AZ
variable "aws_az" {
  type        = string
  description = "AWS AZ"
  default     = "ap-northeast-1a"
}
variable "shared_credentials_files" {
  type    = string
  default = "complete-this"
}

variable "profile" {
  type    = string
  default = "complete-this"
}


# VPC Variables
variable "vpc_cidr" {
  type        = string
  description = "CIDR for the VPC"
  default     = "10.1.64.0/18"
}
# Subnet Variables
variable "public_subnet_cidr" {
  type        = string
  description = "CIDR for the public subnet"
  default     = "10.1.64.0/24"
}
# Subnet Variables
variable "private_subnet_cidr" {
  type        = string
  description = "CIDR for the public subnet"
  default     = "10.1.65.0/24"
}

########################################
## Virtual Machine Module - Variables ##
########################################

variable "linux_instance_type" {
  type        = string
  description = "EC2 instance type for Linux Server"
  default     = "t2.micro"
}

variable "linux_associate_public_ip_address" {
  type        = bool
  description = "Associate a public IP address to the EC2 instance"
  default     = true
}

variable "linux_root_volume_size" {
  type        = number
  description = "Volumen size of root volumen of Linux Server"
  default     = 20
}

variable "linux_data_volume_size" {
  type        = number
  description = "Volumen size of data volumen of Linux Server"
  default     = 10
}

variable "linux_root_volume_type" {
  type        = string
  description = "Volumen type of root volumen of Linux Server. Can be standard, gp3, gp2, io1, sc1 or st1"
  default     = "gp2"
}

variable "linux_data_volume_type" {
  type        = string
  description = "Volumen type of data volumen of Linux Server. Can be standard, gp3, gp2, io1, sc1 or st1"
  default     = "gp2"
}

########################
## F5 XCS Variables   ##
########################

// Required Variable
variable "api_p12_file" {
  type        = string
  description = "REQUIRED:  This is the path to the Volterra API Key.  See https://volterra.io/docs/how-to/user-mgmt/credentials"
  default     = "./api-creds.p12"
}

variable "api_cert" {
  type        = string
  description = "REQUIRED:  This is the path to the Volterra API Key.  See https://volterra.io/docs/how-to/user-mgmt/credentials"
  default     = "./api2.cer"
}
variable "api_key" {
  type        = string
  description = "REQUIRED:  This is the path to the Volterra API Key.  See https://volterra.io/docs/how-to/user-mgmt/credentials"
  default     = "./api.key"
}
// Required Variable
variable "tenant_name" {
  type        = string
  description = "REQUIRED:  This is your Volterra Tenant Name:  https://<tenant_name>.console.ves.volterra.io/api"
  default     = "mr-customer"
}
// Required Variable
variable "namespace" {
  type        = string
  description = "REQUIRED:  This is your Volterra App Namespace"
  default     = "namespace"
}
// Required Variable
variable "xcs_tf_action" {
  default = "plan"
}
variable "delegated_dns_domain" {
  default = "testdomain.com"
}
// Required Variable
variable "api_url" {
  type        = string
  description = "REQUIRED:  This is your Volterra API url"
  default     = "https://playground.console.ves.volterra.io/api"
}
variable "fleet_label" { default = "fleet_label" }

variable "instance_type" {
  description = "XCS EC2 node instance type"
  type        = string
  default     = "t3.xlarge"
}

## TAGS
variable "tags" {
  description = "Environment tags for objects"
  type        = map(string)
  default = {
    purpose     = "public"
    environment = "aws"
    owner       = "f5owner"
    group       = "f5group"
    costcenter  = "f5costcenter"
    application = "f5app"
    creator     = "Terraform"
    delete      = "True"
  }
}
