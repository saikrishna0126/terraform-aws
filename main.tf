# Define local variables for reusability
locals {
  # VPC ID obtained from the AWS VPC resource
  vpc_id = aws_vpc.demo-vpc.id
  # CIDR block for the VPC
  cidr_block = var.aws_vpc_cidr
  # CIDR block for public subnets
  public_subnet_cidr = var.public_subnet_cidr
  # CIDR block for private subnets
  private_subnet_cidr = var.private_subnet_cidr
  # Availability zones for the subnets
  availability_zone = var.azs
}

# Create a VPC resource
resource "aws_vpc" "demo-vpc" {
  cidr_block           = local.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags = {
    Name = "demo vpc"
  }
}

# Create public subnets within the VPC
resource "aws_subnet" "public-subnet" {
  vpc_id            = local.vpc_id
  count             = length(local.public_subnet_cidr)
  cidr_block        = element(local.public_subnet_cidr, count.index)
  availability_zone = element(local.availability_zone, count.index)
  tags = {
    Name = "public subnet ${count.index + 1}"
  }
}

# Create private subnets within the VPC
resource "aws_subnet" "private-subnet" {
  vpc_id            = local.vpc_id
  count             = length(local.private_subnet_cidr)
  cidr_block        = element(local.private_subnet_cidr, count.index)
  availability_zone = element(local.availability_zone, count.index)
  tags = {
    Name = "private subnet ${count.index + 1}"
  }
}

# Create an internet gateway for the VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = local.vpc_id
  tags = {
    Name = "vpc igw"
  }
}

# Create a public route table and associate it with the VPC
resource "aws_route_table" "public-route-table" {
  vpc_id = local.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Create a private route table and associate it with the VPC
resource "aws_route_table" "private-route-table" {
  vpc_id = local.vpc_id
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public-subnet-association" {
  count          = length(local.public_subnet_cidr)
  subnet_id      = aws_subnet.public-subnet[count.index].id
  route_table_id = aws_route_table.public-route-table.id
}

# Associate private subnets with the private route table
resource "aws_route_table_association" "private-subnet-association" {
  count          = length(local.private_subnet_cidr)
  subnet_id      = aws_subnet.private-subnet[count.index].id
  route_table_id = aws_route_table.private-route-table.id
}

# Create a security group for instances in the VPC
resource "aws_security_group" "demo-sg" {
  vpc_id = aws_vpc.demo-vpc.id
  name   = "demo-sg"

  # Allow inbound traffic on specified ports
  ingress {
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = var.https_port
    to_port     = var.https_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "demo-sg"
  }
}

# Create EC2 instances within the VPC
resource "aws_instance" "demo" {
  count = length(var.instance_names)

  ami           = var.ami_id
  instance_type = var.instance_types[count.index]

  # Assign instances to either public or private subnets based on count index
  subnet_id                   = count.index == 0 ? aws_subnet.public-subnet[0].id : aws_subnet.private-subnet[0].id
  security_groups             = [aws_security_group.demo-sg]
  associate_public_ip_address = true
}

# Resource block for creating EBS volumes
resource "aws_ebs_volume" "demo-ebs" {
  count             = length(var.instance_names)
  # Size of the EBS volume in gigabytes
  size              = var.ebs_volume_size
  # Type of EBS volume (e.g., gp2, io1)
  type              = var.ebs_volume_type
  # Availability zone for the volume
  availability_zone = element(local.availability_zone, count.index)
  # Tagging the EBS volume
  tags = {
    Name = "demo-ebs-${count.index + 1}"
  }
}

# Resource block for attaching EBS volumes to instances
resource "aws_volume_attachment" "demo-ebs-attachment" {
  count       = length(var.instance_names)
  # ID of the instance
  instance_id = aws_instance.demo[count.index].id
  # ID of the EBS volume to attach
  volume_id   = aws_ebs_volume.demo-ebs[count.index].id
  # Device name to attach the volume to on the instance (e.g., /dev/sdf)
  device_name = var.ebs_device_name
}

# Define your RDS security group
resource "aws_security_group" "my_rds_sg" {
  name        = "my-rds-sg"
  description = "Security group for RDS instance"
  vpc_id      = aws_vpc.demo-vpc.id
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# Define your RDS subnet group
resource "aws_db_subnet_group" "my_db_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = [for subnet in aws_subnet.private-subnet : subnet.id]
  tags = {
    Name = "MyDBSubnetGroup"
  }
}


