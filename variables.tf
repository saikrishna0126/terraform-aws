# Define a variable for availability zones
variable "azs" {
  type    = list(string)
  default = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}

# Define a variable for the VPC CIDR block
variable "aws_vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

# Define a variable for public subnet CIDR blocks
variable "public_subnet_cidr" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

# Define a variable for private subnet CIDR blocks
variable "private_subnet_cidr" {
  type    = list(string)
  default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

# Define a variable for HTTP port
variable "http_port" {
  description = "The port number for HTTP traffic"
  type        = number
  default     = 80
}

# Define a variable for HTTPS port
variable "https_port" {
  description = "The port number for HTTPS traffic"
  type        = number
  default     = 443
}

# Define a variable for SSH port
variable "ssh_port" {
  description = "The port number for SSH traffic"
  type        = number
  default     = 22
}

# Define a variable for EC2 instance types
variable "instance_types" {
  description = "List of instance types for EC2 instances"
  default     = ["t2.large", "t2.micro"]
}

# Define a variable for EC2 instance names
variable "instance_names" {
  description = "List of instance names for EC2 instances"
  default     = ["public-1", "private-2"]
}

# Define a variable for AMI ID
variable "ami_id" {
  default     = ""
  description = ""
}

variable "ebs_volume_size" {
  description = "The size of the EBS volume in gigabytes"
  type        = number
}

variable "ebs_volume_type" {
  description = "The type of EBS volume (e.g., gp2, io1)"
  type        = string
}

variable "ebs_device_name" {
  description = "The device name to attach the EBS volume to on the instance (e.g., /dev/sdf)"
  type        = string
}
