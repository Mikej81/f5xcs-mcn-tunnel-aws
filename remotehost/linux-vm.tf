###################################
## Virtual Machine Module - Main ##
###################################

# Create Elastic IP for the EC2 instance
resource "aws_eip" "linux-eip" {
  vpc = true

  tags = {
    Name        = "${lower(var.name)}-${var.environment}-linux-eip"
    Environment = var.environment
  }
}

output "aws_eip_linux_public_dns" {
  value = aws_eip.linux-eip.public_dns
}

data "template_file" "init" {
  template = templatefile("${path.module}/../templates/cloud-init.yaml", {
    owner = var.tags["owner"]
    #fqdn     = var.publicip
    fqdn     = aws_eip.linux-eip.public_dns
    password = var.adminPassword
  })

}
data "template_file" "script" {
  template = templatefile("${path.module}/../templates/init.sh", {
  })
}

data "template_cloudinit_config" "cloud_init" {
  gzip          = true
  base64_encode = true

  # Main cloud-config configuration file.
  part {
    filename     = "cloud-init.yaml"
    content_type = "text/cloud-config"
    content      = data.template_file.init.rendered
  }
  part {
    filename     = "init.sh"
    content_type = "text/x-shellscript"
    content      = data.template_file.script.rendered
  }
}

# Create EC2 Instance
resource "aws_instance" "linux-server" {
  ami                         = data.aws_ami.ubuntu-linux-1804.id
  instance_type               = var.linux_instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.aws-linux-sg.id]
  associate_public_ip_address = var.linux_associate_public_ip_address
  source_dest_check           = false
  key_name                    = var.key_name
  user_data                   = data.template_cloudinit_config.cloud_init.rendered

  # root disk
  root_block_device {
    volume_size           = var.linux_root_volume_size
    volume_type           = var.linux_root_volume_type
    delete_on_termination = true
    encrypted             = true
  }

  # extra disk
  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_size           = var.linux_data_volume_size
    volume_type           = var.linux_data_volume_type
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name        = "${lower(var.name)}-${var.environment}-linux-server"
    Environment = var.environment
    owner       = var.owner
  }
}

output "aws_eip_linux_private_ip" {
  value = aws_instance.linux-server.private_ip
}

# Associate Elastic IP to Linux Server
resource "aws_eip_association" "linux-eip-association" {
  instance_id   = aws_instance.linux-server.id
  allocation_id = aws_eip.linux-eip.id
}

# Define the security group for the Linux server
resource "aws_security_group" "aws-linux-sg" {
  name        = "${lower(var.name)}-${var.environment}-linux-sg"
  description = "Allow incoming HTTP connections"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming HTTP connections"
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    #cidr_blocks = ["0.0.0.0/0"]
    cidr_blocks = ["${var.security_source}/32"]
    description = "Allow incoming SSH connections"
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all ICMP"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming All connections"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${lower(var.name)}-${var.environment}-linux-sg"
    Environment = var.environment
  }
}
resource "local_file" "onboard_init" {
  content  = data.template_file.init.rendered
  filename = "${path.module}/../outputs/cloud-rendered.yaml"
}
resource "local_file" "onboard_script" {
  content  = data.template_file.script.rendered
  filename = "${path.module}/../outputs/script.sh"
}
