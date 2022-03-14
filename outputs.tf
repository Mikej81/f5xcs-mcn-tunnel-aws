## OUTPUTS ###

output "auto_tag" {
  value = {
    #resource_group = module.azure.azure_resource_group_main.name
    #volt_group     = module.volterra.volterra_resource_group.name
    #tags           = module.volterra.volterra_resource_group_tags
  }
}

output "deployment_info" {
  value = {
    instances = [
      {
        admin_username = var.adminUserName
        admin_password = module.util.admin_password
        host_mapping   = "sudo -- sh -c 'echo ${module.remotehost.aws_eip_linux_private_ip}   ${module.remotehost.aws_eip_linux_public_dns} >> /etc/hosts'"
        connect        = "echo -n ${module.util.admin_password} | sudo openconnect -b ${module.remotehost.aws_eip_linux_public_dns} -u vpnuser --passwd-on-stdin"
      }
    ]
    deploymentId = module.util.env_prefix
  }
}
