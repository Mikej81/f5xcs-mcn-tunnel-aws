#####################
## Key Pair - Main ##
#####################

# Generates a secure private key and encodes it as PEM
resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create the Key Pair
resource "aws_key_pair" "key_pair" {
  key_name   = "${lower(var.name)}-${lower(var.environment)}-${lower(var.aws_region)}"
  public_key = tls_private_key.key_pair.public_key_openssh
}

# Save file
resource "local_file" "ssh_key" {
  filename        = "${aws_key_pair.key_pair.key_name}.pem"
  file_permission = "600"
  content         = tls_private_key.key_pair.private_key_pem
}

output "aws_key_pair_key_pair_key_name" {
  value = aws_key_pair.key_pair.key_name
}
