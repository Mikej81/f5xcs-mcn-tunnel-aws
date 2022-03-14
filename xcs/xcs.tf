terraform {
  required_version = ">= 0.12"
  required_providers {
    volterra = {
      source  = "volterraedge/volterra"
      version = "0.11.3"
    }
  }
}

resource "volterra_token" "new_site" {
  name      = format("%s-sca-token", var.name)
  namespace = "system"

  #labels = var.tags
}

output "token" {
  value = volterra_token.new_site.id
}

resource "volterra_cloud_credentials" "aws_cc" {
  name      = format("%s-aws-credentials", var.name)
  namespace = "system"

  aws_secret_key {
    access_key = var.aws_access_key

    secret_key {
      clear_secret_info {
        url = "string:///${base64encode(var.aws_secret_key)}"
      }
    }
  }

}

output "credentials" {
  value = volterra_cloud_credentials.aws_cc.name
}


# resource "volterra_virtual_network" "inside" {
#   name      = format("%s-inside", var.name)
#   namespace = "system"

#   site_local_inside_network = true
# }
# resource "volterra_virtual_network" "outside" {
#   name      = format("%s-outside", var.name)
#   namespace = "system"

#   site_local_network = true
# }
resource "volterra_virtual_network" "global" {
  name      = format("%s-global", var.name)
  namespace = "system"

  global_network = true
}

# resource "volterra_network_connector" "snat" {
#   name      = format("%s-connector-snat", var.name)
#   namespace = "system"

#   sli_to_global_snat {
#     global_vn {
#       name      = volterra_virtual_network.global.name
#       namespace = "system"
#       #tenant    = var.volterra_tenant
#     }
#     snat_config {
#       interface_ip    = true
#       dynamic_routing = true
#     }
#   }

#   disable_forward_proxy = true
# }

resource "volterra_network_connector" "direct" {
  name      = format("%s-global-direct-connect", var.name)
  namespace = "system"

  sli_to_global_dr {
    global_vn {
      name      = volterra_virtual_network.global.name
      namespace = "system"
      #tenant    = var.volterra_tenant
    }

  }

  disable_forward_proxy = true
}

resource "volterra_aws_vpc_site" "aws_vpc_site" {
  depends_on = [
    volterra_cloud_credentials.aws_cc
  ]

  name       = format("%s-vpc-site", var.name)
  namespace  = "system"
  aws_region = var.aws_region

  aws_cred {
    name      = volterra_cloud_credentials.aws_cc.name
    namespace = "system"
  }
  vpc {
    vpc_id = var.aws_vpc_id
  }
  ingress_egress_gw {
    aws_certified_hw = "aws-byol-multi-nic-voltmesh"

    az_nodes {
      aws_az_name = var.aws_az
      disk_size   = "80"

      inside_subnet {
        existing_subnet_id = var.aws_private_subnet_id
      }
      outside_subnet {
        existing_subnet_id = var.aws_public_subnet_id
      }
    }

    no_inside_static_routes = true
    # inside_static_routes {
    #   static_route_list {
    #     simple_static_route = var.vpc_cidr
    #   }
    # }

    global_network_list {
      global_network_connections {
        sli_to_global_dr {
          global_vn {
            namespace = "system"
            name      = volterra_virtual_network.global.name
          }
        }
      }
    }
    no_outside_static_routes = true
    no_network_policy        = true
    no_forward_proxy         = true

  }

  instance_type           = var.instance_type
  logs_streaming_disabled = true
  ssh_key                 = var.sshPublicKey
  lifecycle {
    ignore_changes = [labels]
  }

  provisioner "local-exec" {
    when    = destroy
    command = "sleep 5s"
  }

}

resource "volterra_tf_params_action" "apply_aws_vpc" {
  site_name        = volterra_aws_vpc_site.aws_vpc_site.name
  site_kind        = "aws_vpc_site"
  action           = var.xcs_tf_action
  wait_for_action  = true
  ignore_on_update = true
}
