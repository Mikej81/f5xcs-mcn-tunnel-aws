# main.tf

# Util Module
# - Random Prefix Generation
# - Random Password Generation
module "util" {
  source = "./util"
}

# AWS Module
# Create all AWS Dependencies
module "aws" {
  source              = "./aws"
  projectPrefix       = module.util.env_prefix
  name                = var.name
  environment         = var.environment
  aws_region          = var.aws_region
  aws_az              = var.aws_az
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
}

module "xcs" {
  source                = "./xcs"
  projectPrefix         = module.util.env_prefix
  name                  = var.name
  namespace             = var.namespace
  tenant_name           = var.tenant_name
  environment           = var.environment
  fleet_label           = var.fleet_label
  api_url               = var.api_url
  sshPublicKeyPath      = var.sshPublicKeyPath
  sshPublicKey          = var.sshPublicKey
  api_p12_file          = var.api_p12_file
  aws_region            = var.aws_region
  aws_az                = var.aws_az
  aws_access_key        = var.aws_access_key
  aws_secret_key        = var.aws_secret_key
  aws_vpc_id            = module.aws.aws_vpc_vpc_id
  aws_public_subnet_id  = module.aws.aws_public_subnet_id
  public_subnet_cidr    = var.public_subnet_cidr
  private_subnet_cidr   = var.private_subnet_cidr
  aws_private_subnet_id = module.aws.aws_private_subnet_id
  vpc_cidr              = var.vpc_cidr
  xcs_tf_action         = var.xcs_tf_action
  delegated_dns_domain  = var.delegated_dns_domain
  instance_type         = var.instance_type
  tags                  = var.tags
}

# Remote Host Module
# Create Linux VM with all Dependencies
module "remotehost" {
  depends_on = [
    module.aws.aws_vpc_vpc_id
  ]
  source                            = "./remotehost"
  projectPrefix                     = module.util.env_prefix
  name                              = var.name
  environment                       = var.environment
  adminUserName                     = var.adminUserName
  adminPassword                     = module.util.admin_password
  aws_region                        = var.aws_region
  aws_az                            = var.aws_az
  vpc_id                            = module.aws.aws_vpc_vpc_id
  key_name                          = module.aws.aws_key_pair_key_pair_key_name
  subnet_id                         = module.aws.aws_private_subnet_id
  linux_data_volume_size            = var.linux_data_volume_size
  linux_root_volume_type            = var.linux_root_volume_type
  linux_data_volume_type            = var.linux_data_volume_type
  linux_instance_type               = var.linux_instance_type
  linux_root_volume_size            = var.linux_root_volume_size
  linux_associate_public_ip_address = var.linux_associate_public_ip_address
  owner                             = var.tags["owner"]
  tags                              = var.tags
  security_source                   = module.util.local_public_ip
}
