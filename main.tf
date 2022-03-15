# main.tf

# Util Module
# - Random Prefix Generation
# - Random Password Generation
module "util" {
  source = "./util"
}

module "xcs" {
  source               = "./xcs"
  projectPrefix        = module.util.env_prefix
  name                 = var.name
  namespace            = var.namespace
  tenant_name          = var.tenant_name
  environment          = var.environment
  fleet_label          = var.fleet_label
  api_url              = var.api_url
  sshPublicKeyPath     = var.sshPublicKeyPath
  sshPublicKey         = var.sshPublicKey
  api_p12_file         = var.api_p12_file
  aws_region           = var.aws_region
  aws_az               = var.aws_az
  aws_access_key       = var.aws_access_key
  aws_secret_key       = var.aws_secret_key
  public_subnet_cidr   = var.public_subnet_cidr
  private_subnet_cidr  = var.private_subnet_cidr
  vpc_cidr             = var.vpc_cidr
  xcs_tf_action        = var.xcs_tf_action
  delegated_dns_domain = var.delegated_dns_domain
  instance_type        = var.instance_type
  tags                 = var.tags
}
