terraform {
  required_version = ">= 0.12"
  required_providers {
    volterra = {
      source  = "volterraedge/volterra"
      version = "0.11.6"
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

resource "volterra_virtual_network" "global" {
  name      = format("%s-global-network", var.name)
  namespace = "system"

  global_network = true
}

resource "volterra_network_connector" "direct" {
  name      = format("%s-global-direct-cloud", var.name)
  namespace = "system"

  description = "Global Network Connector for Cloud Site."

  slo_to_global_dr {
    global_vn {
      name      = volterra_virtual_network.global.name
      namespace = "system"
    }

  }

  disable_forward_proxy = true
}

resource "volterra_network_connector" "local" {
  name      = format("%s-global-direct-fleet", var.name)
  namespace = "system"

  decription = "Global Network Connector for Local Fleet."

  sli_to_global_dr {
    global_vn {
      name      = volterra_virtual_network.global.name
      namespace = "system"
    }

  }

  disable_forward_proxy = true
}

output "xcs_global_connector_local" {
  value = volterra_network_connector.local.name
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
    new_vpc {
      autogenerate = true
      primary_ipv4 = var.vpc_cidr
    }
  }

  ingress_egress_gw {
    aws_certified_hw = "aws-byol-multi-nic-voltmesh"

    az_nodes {
      aws_az_name = var.aws_az
      disk_size   = "80"

      inside_subnet {
        subnet_param {
          ipv4 = var.private_subnet_cidr
        }
      }
      outside_subnet {
        subnet_param {
          ipv4 = var.public_subnet_cidr
        }
      }
    }

    no_inside_static_routes = true

    outside_static_routes {
      static_route_list {
        simple_static_route = "8.8.8.8/32"
      }
      static_route_list {
        simple_static_route = "8.8.4.4/32"
      }
      static_route_list {
        simple_static_route = "128.0.0.0/1"
      }
      static_route_list {
        simple_static_route = "0.0.0.0/1"
      }
    }

    no_network_policy = true
    no_forward_proxy  = true

    global_network_list {
      global_network_connections {
        slo_to_global_dr {
          global_vn {
            namespace = "system"
            name      = volterra_virtual_network.global.name
          }
        }
      }
    }

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
