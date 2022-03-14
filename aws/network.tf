##########################################
## Network Single AZ Public Only - Main ##
##########################################

# Create the VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name        = "${lower(var.name)}-${lower(var.environment)}-vpc"
    Environment = var.environment
  }
}

# Define the public subnet
resource "aws_subnet" "public-subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = var.aws_az
  tags = {
    Name        = "${lower(var.name)}-${lower(var.environment)}-public-subnet"
    Environment = var.environment
  }
}

# Define the private subnet
resource "aws_subnet" "private-subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.aws_az
  tags = {
    Name        = "${lower(var.name)}-${lower(var.environment)}-private-subnet"
    Environment = var.environment
  }
}

# Define the internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
  #route_table_id = aws_route_table.public-rt.id

  tags = {
    Name        = "${lower(var.name)}-${lower(var.environment)}-igw"
    Environment = var.environment
  }
}

# Define the public route table
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name        = "${lower(var.name)}-${lower(var.environment)}-public-subnet-rt"
    Environment = var.environment
  }
}

# Assign the public route table to the public subnet
resource "aws_route_table_association" "public-rt-association" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-rt.id
}

output "aws_vpc_vpc_id" {
  value = aws_vpc.vpc.id
}

output "aws_public_subnet_id" {
  value = aws_subnet.public-subnet.id
}

output "aws_private_subnet_id" {
  value = aws_subnet.private-subnet.id
}

